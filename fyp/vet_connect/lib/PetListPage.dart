import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'PetDetailsPage.dart';
import 'PetDataPage.dart'; // Import PetDataPage

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  _PetListPageState createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool _isDeleting = false; // Toggle for delete mode
  final Set<String> _selectedPets = {}; // Store selected pet IDs

  @override
  Widget build(BuildContext context) {
    final String? uid = auth.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pet List'),
        ),
        body: const Center(
          child: Text('No user is logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          if (_isDeleting)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedPets,
            ),
          IconButton(
            icon: Icon(_isDeleting ? Icons.cancel : Icons.delete),
            onPressed: () {
              setState(() {
                _isDeleting = !_isDeleting;
                _selectedPets.clear();
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('pets').where('uid', isEqualTo: uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching pet data'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pets added yet.'));
          }

          final pets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final petData = pets[index].data() as Map<String, dynamic>;
              final petId = pets[index].id;
              final bool isSelected = _selectedPets.contains(petId);

              return GestureDetector(
                onTap: () {
  if (_isDeleting) {
    _toggleSelection(petId);
  } else {
    // Convert petData from Map<String, dynamic> to Map<String, String>
    Map<String, String> petStringData = petData.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    // Navigate to PetDataPage with the converted data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDataPage(pet: petStringData),
      ),
    );
  }
},

                child: Card(
                  color: isSelected ? Colors.red.shade100 : null,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: petData['imagePath'] != null
                        ? Image.network(
                            petData['imagePath'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.pets),
                    title: Text(petData['petName'] ?? 'Unnamed Pet'),
                    subtitle: Text('${petData['petCategory']}, ${petData['petAge']} years old'),
                    trailing: _isDeleting
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(petId),
                          )
                        : IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetDetailsPage(
                                    pet: petData.map((key, value) => MapEntry(key, value.toString())),
                                    onSave: (updatedPet) {
                                      firestore.collection('pets').doc(petId).update(updatedPet).then((_) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Pet details updated successfully')),
                                        );
                                      }).catchError((error) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error updating pet: $error')),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetDetailsPage(
                pet: const {},
                onSave: (newPet) {
                  final String id = DateTime.now().microsecondsSinceEpoch.toString();
                  firestore.collection('pets').doc(id).set({
                    ...newPet,
                    'id': id,
                    'uid': uid,
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pet added successfully')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding pet: $error')),
                    );
                  });
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _toggleSelection(String petId) {
    setState(() {
      if (_selectedPets.contains(petId)) {
        _selectedPets.remove(petId);
      } else {
        _selectedPets.add(petId);
      }
    });
  }

  void _deleteSelectedPets() {
    for (String petId in _selectedPets) {
      firestore.collection('pets').doc(petId).delete().catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting pet: $error')),
        );
      });
    }
    setState(() {
      _isDeleting = false;
      _selectedPets.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected pets deleted successfully')),
    );
  }
}
