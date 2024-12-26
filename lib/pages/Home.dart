import 'package:flutter/material.dart';
import 'package:tradermind/pages/Add_Entry.dart';
import 'package:tradermind/pages/Calendar.dart';
import 'package:tradermind/pages/Favourite.dart';
import 'package:tradermind/pages/Login.dart';
import 'package:tradermind/pages/user/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradermind/pages/EditEntryPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Track the selected tab
  final List<Widget> _pages = []; // Keep pages in memory

  @override
  void initState() {
    super.initState();
    // Initialize the pages only once to persist state
    _pages.add(JournalEntriesList());
    _pages.add(CalendarViewPage());
    _pages.add(FavoritesPage());
    _pages.add(ProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('Home'),
              backgroundColor: const Color(0xFF00C98E),
              automaticallyImplyLeading: false,
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
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
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
            )
          : null, // AppBar only for the home tab

      body: _pages[_currentIndex], // Use persistent pages

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        backgroundColor: const Color(0xFF00C98E),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
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
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class JournalEntriesList extends StatefulWidget {
  const JournalEntriesList({Key? key}) : super(key: key);

  @override
  _JournalEntriesListState createState() => _JournalEntriesListState();
}

class _JournalEntriesListState extends State<JournalEntriesList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text("User not logged in"));
    }

    final String userId = user.uid;
    print('User ID: $userId'); // Debugging: Print user ID

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('journalEntries')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        print(
            'Snapshot connection state: ${snapshot.connectionState}'); // Debugging state

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("Error: ${snapshot.error}"); // Debugging error logs
          return const Center(child: Text('An error occurred.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No journal entries found.'));
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
            final documentId = entry.id; // Getting the document ID
            // Use null-aware operator to avoid errors when the field is missing
            final isFavorite = entry['favorite'] ?? false;

            // Set color for each trade result
            Color resultColor = Colors.black;
            String resultText = tradeResult;

            if (tradeResult.toLowerCase() == 'win') {
              resultColor = Colors.green;
            } else if (tradeResult.toLowerCase() == 'loss') {
              resultColor = Colors.red;
            } else if (tradeResult.toLowerCase() == 'breakeven') {
              resultColor = Colors.blue;
            }

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
                      'Result: $resultText',
                      style: TextStyle(
                          color: resultColor), // Apply the result color
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String value) async {
                    if (value == 'Edit') {
                      // Handle Edit action: Navigate to edit page
                      print('Edit entry: $documentId');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditEntryPage(
                            documentId: documentId,
                            pairsIndex: pairsIndex,
                            entryDate: entryDate,
                            tradeResult: tradeResult,
                            confluences: confluences,
                            recap: recap,
                            session: session,
                            trend: trend,
                          ),
                        ),
                      );
                    } else if (value == 'Set Favourite') {
                      // Handle Set Favourite functionality
                      await _toggleFavorite(entry.id, !isFavorite);
                    } else if (value == 'Delete') {
                      // Show the confirmation dialog
                      _showDeleteConfirmationDialog(context, documentId);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'Edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Set Favourite',
                        child: Row(
                          children: [
                            Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(isFavorite
                                ? 'Remove from Favorites'
                                : 'Set Favourite'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Method to toggle favorite status
  Future<void> _toggleFavorite(String entryId, bool isFavorite) async {
    try {
      await FirebaseFirestore.instance
          .collection('journalEntries')
          .doc(entryId)
          .update({
        'favorite': isFavorite,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        ),
      );

      setState(() {}); // Trigger a rebuild to reflect updated data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorite: $e')),
      );
    }
  }

  // Function to show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text("Do you want to delete this entry?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                // Delete the document
                try {
                  await FirebaseFirestore.instance
                      .collection('journalEntries')
                      .doc(documentId)
                      .delete();
                  Navigator.of(context)
                      .pop(); // Close the dialog after deletion
                  print('Entry deleted');

                  // Show a success message using a SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Entry deleted successfully!'),
                      backgroundColor: Color(0xFF00C98E),
                    ),
                  );
                } catch (e) {
                  print('Error deleting entry: $e');
                }
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
