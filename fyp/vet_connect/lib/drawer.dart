import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:vet_connect/PetListPage.dart';

class MyDrawer extends StatefulWidget {
  final String profileImageUrl; // User's profile image URL

  const MyDrawer(
      {super.key,
      required this.profileImageUrl,
      required String email,
      required Null Function() onLogout});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String userEmail = "Loading..."; // Default text while fetching email

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail =
          user?.email ?? "No Email Found"; // Set the email or default text
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log out from Firebase
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Redirect to login page
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(userEmail), // Dynamically fetched email
            accountName: const Text(
              "Welcome!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // currentAccountPicture: CircleAvatar(
            //   backgroundImage: widget.profileImageUrl.isNotEmpty
            //       ? NetworkImage(widget.profileImageUrl)
            //       : const AssetImage('assets/default_profile.png') as ImageProvider,
            // ),
            decoration: BoxDecoration(
              color: Colors.deepPurple[500], // Drawer header background color
            ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.pets),
          //   title: const Text('Pet Profiles'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => PetListPage()),
          //     );
          //   },
          // ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}
