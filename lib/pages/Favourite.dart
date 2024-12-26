import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tradermind/pages/Add_Entry.dart';
import 'package:tradermind/pages/Login.dart';
import 'package:tradermind/pages/user/Profile.dart'; // Assuming you have this page for Profile

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Set<String> _processingEntries = {}; // Tracks entries being updated

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          backgroundColor: const Color(0xFF00C98E),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You must be logged in to view favorites.'),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFF00C98E),
        automaticallyImplyLeading: false, // Removes the back button
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu), // Hamburger icon
            onSelected: (String value) async {
              if (value == 'My Profile') {
                // Navigate to ProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (value == 'Logout') {
                // Handle Logout
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'My Profile',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('My Profile'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('journalEntries')
            .where('favorite', isEqualTo: true)
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No favorite entries yet.'));
          }

          final entries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final pairsIndex = entry['pairsIndex'] ?? 'No Pair/Index';
              final entryDate = entry['entryDate'] ?? 'N/A';
              final tradeResult = entry['tradeResult'] ?? 'N/A';
              final confluences = entry['confluences'] ?? 'No Confluences';
              final recap = entry['recap'] ?? 'No Recap';
              final session = entry['session'] ?? 'No Session';
              final trend = entry['trend'] ?? 'No Trend';
              final documentId = entry.id;
              final isFavorite = entry['favorite'] ?? false;

              Color resultColor = Colors.black;
              if (tradeResult.toLowerCase() == 'win')
                resultColor = Colors.green;
              if (tradeResult.toLowerCase() == 'loss') resultColor = Colors.red;
              if (tradeResult.toLowerCase() == 'breakeven')
                resultColor = Colors.blue;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(pairsIndex),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: $entryDate'),
                      Text('Confluences: $confluences'),
                      Text('Recap: $recap'),
                      Text('Session: $session'),
                      Text('Trend: $trend'),
                      Text(
                        'Result: $tradeResult',
                        style: TextStyle(color: resultColor),
                      ),
                    ],
                  ),
                  trailing: _processingEntries.contains(documentId)
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () =>
                              _toggleFavorite(documentId, isFavorite),
                        ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 10), // Adjusts the button's vertical position
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEntryPage(
                  onSave: () {
                    setState(() {}); // Refresh after adding an entry
                  },
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFF00C98E),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _toggleFavorite(String documentId, bool isFavorite) async {
    setState(() {
      _processingEntries.add(documentId); // Show loading only for this item
    });

    try {
      await FirebaseFirestore.instance
          .collection('journalEntries')
          .doc(documentId)
          .update({'favorite': !isFavorite});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isFavorite ? 'Removed successfully' : 'Added to favorites'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _processingEntries.remove(documentId); // Remove loading for this item
      });
    }
  }
}
