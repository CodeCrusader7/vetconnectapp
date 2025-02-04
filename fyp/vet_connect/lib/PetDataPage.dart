import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vet_connect/RecordDetailsPage.dart';
import 'dart:io';
import 'PetProfilePage.dart';
import 'MedicalRecordsPage.dart';

class PetDataPage extends StatelessWidget {
  final Map<String, String> pet; // Accept pet data in the constructor

  PetDataPage({required this.pet});

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final String? uid = auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context); // Navigate back
            }),
        title: const Text(
          'Pet Data',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // "RECORDS" and "PROFILE" below the AppBar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordDetailsPage(
                          petId: pet['id']!,
                          recordId: '',
                        ),
                      ),
                    ); // Stay on the current page
                  },
                  child: const Text(
                    'RECORDS',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (uid != null) {
                      // Fetch pet profile data from Firestore
                      DocumentSnapshot petDoc = await firestore
                          .collection('pets')
                          .doc(pet['id'])
                          .get();

                      if (petDoc.exists) {
                        Map<String, dynamic> petData =
                            petDoc.data() as Map<String, dynamic>;

                        // Convert Map<String, dynamic> to Map<String, String>
                        Map<String, String> petStringData = petData.map(
                            (key, value) => MapEntry(key, value.toString()));

                        // Navigate to PetProfilePage with the converted data
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return PetProfilePage(pet: petStringData);
                            },
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                  position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Pet profile not found')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'PROFILE',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[300]),

          // Main content to display pet's information
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display pet's image (if available) or default icon
                  // pet['imagePath'] != null
                  //     ? ClipOval(
                  //         child: Image.file(
                  //           File(pet['imagePath']!),
                  //           width: 100,
                  //           height: 100,
                  //           fit: BoxFit.cover,
                  //         ),
                  //       )
                  //     : const ClipOval(
                  //         child: Icon(
                  //           Icons.pets,
                  //           size: 100,
                  //           color: Colors.purple,
                  //         ),
                  //       ),
                  const SizedBox(height: 20),
                  Text(
                    'Name: ${pet['petName'] ?? 'No Name'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Type: ${pet['petCategory'] ?? 'No Category'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (uid != null) {
                        // Navigate to MedicalRecordsPage and save record in Firestore
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicalRecordsPage(
                              petId: pet[
                                  'id']!, // Pass UID for Firestore record saving
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Error: User not logged in')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
