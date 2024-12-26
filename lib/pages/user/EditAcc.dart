import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load user data
  void _loadUserData() {
    final User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? '';
        _usernameController.text = user.displayName ?? '';
      });
    }
  }

  // Save changes
  void _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        // Update user display name
        await user.updateDisplayName(_usernameController.text.trim());
        await user.reload(); // Reload the user to reflect changes

        // Save only the username to Firestore
        await _firestore.collection('users').doc(user.uid).set(
          {
            'username': _usernameController.text.trim(),
          },
          SetOptions(merge: true), // Merge with existing data
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")),
        );

        Navigator.pop(context, true); // Pass true to indicate a change was made
      }
    } catch (e) {
      print("Error saving changes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile")),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00C98E),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Make the page scrollable to avoid overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Account Icon
              Center(
                child: Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Color(0xFF00C98E),
                ),
              ),
              const SizedBox(height: 20),
              // Username Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Email Field (Read-Only)
              TextField(
                controller: _emailController,
                readOnly: true, // Make this field read-only
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Save Changes Button
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : _saveChanges, // Disable button when saving
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C98E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors
                            .white) // Show progress indicator while saving
                    : const Text(
                        "Save Changes",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
