import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this for Firebase Auth
import 'package:vet_connect/PetListPage.dart';
import 'online_consultation.dart';

class MyDrawer extends StatelessWidget {
  final String email; // The user's email
  final String profileImageUrl; // The user's profile image URL

  MyDrawer({
    required this.email,
    required this.profileImageUrl, required Null Function() onLogout,
  });

  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log out from Firebase
    Navigator.of(context).pushReplacementNamed('/login'); // Redirect to login page
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(email),
            accountName: Text(
              "Welcome!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple[500], // Drawer header background color
            ),
          ),
          ListTile(
            leading: Icon(Icons.pets),
            title: Text('Pet Profiles'),
            onTap: () {
              // Navigate to pet profiles screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetListApp()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}
