import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vet_connect/edit_pet_details_screen.dart';
import 'dart:io';
import 'PetDetailsPage.dart';
import 'PetProfilePage.dart';

void main() {
  runApp(PetListApp());
}

class PetListApp extends StatelessWidget {
  const PetListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PetListPage(),
    );
  }
}

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  _PetListPageState createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  List<Map<String, String>> pets = [];

  void _addPet(Map<String, String> pet) {
    setState(() {
      pets.add(pet);
    });
  }

  void _editPet(int index, Map<String, String> updatedPet) {
    setState(() {
      pets[index] = updatedPet;
    });
  }

  void _deletePet(int index) {
    setState(() {
      pets.removeAt(index);
    });
  }

  void _navigateToPetDetails({required bool isNew, int? index}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailsPage(
          pet: isNew ? {} : pets[index!],
          onSave: (updatedPet) {
            if (isNew) {
              _addPet(updatedPet);
            } else {
              _editPet(index!, updatedPet);
            }
          },
        ),
      ),
    );
  }

  void _showEditDialog() {
    final firestore = FirebaseFirestore.instance.collection('pets').snapshots();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Profile to Edit'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore,
              builder: (BuildContext context, AsyncSnapshot snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshots.hasError) {
                  return const Text('Some Error');
                }
                return ListView.builder(
                  itemCount: snapshots.data.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshots.data.docs[index]['petName']),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPetDetailsScreen(
                                imageUrl: snapshots.data.docs[index]
                                    ['imagePath'],
                                petName: snapshots.data.docs[index]['petName'],
                                petCategory: snapshots.data.docs[index]
                                    ['petCategory'],
                                petAge: snapshots.data.docs[index]['petAge'],
                                petGender: snapshots.data.docs[index]
                                    ['petGender'],
                                petWeight: snapshots.data.docs[index]
                                    ['petWeight'],
                                petWeightUnit: snapshots.data.docs[index]
                                    ['petWeightUnit'],
                                petColor: snapshots.data.docs[index]
                                    ['petColor'],
                                petBreed: snapshots.data.docs[index]
                                    ['petBreed'],
                                id: snapshots.data.docs[index]['id'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog() {
    final firestore = FirebaseFirestore.instance.collection('pets').snapshots();
    CollectionReference ref = FirebaseFirestore.instance.collection('pets');
    final ref1 = FirebaseFirestore.instance.collection('pets');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Profile to Delete'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore,
              builder: (BuildContext context, AsyncSnapshot snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshots.hasError) {
                  return const Text('Some Error');
                }
                return ListView.builder(
                  itemCount: snapshots.data.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshots.data.docs[index]['petName']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref
                              .doc(snapshots.data.docs[index]['id'].toString())
                              .delete()
                              .then(
                            (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Successfully Deleted',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  final firestore = FirebaseFirestore.instance.collection('pets').snapshots();
  CollectionReference ref = FirebaseFirestore.instance.collection('pets');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore,
        builder: (BuildContext context, AsyncSnapshot snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshots.hasError) {
            return const Text('Some Error');
          }
          return ListView.builder(
            itemCount: snapshots.data.docs.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: ListTile(
                  leading: snapshots.data.docs[index]['imagePath'] != null ||
                          snapshots.data.docs[index]['imagePath'].isEmpty
                      ? Image.network(
                          snapshots.data.docs[index]['imagePath'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.pets),
                  title:
                      Text(snapshots.data.docs[index]['petName'] ?? 'No Name'),
                  subtitle: Text(snapshots.data.docs[index]['petCategory'] ??
                      'No Category'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetProfilePage(
                          image: snapshots.data.docs[index]['imagePath'],
                          name: snapshots.data.docs[index]['petName'],
                          type: snapshots.data.docs[index]['petBreed'],
                          age: snapshots.data.docs[index]['petAge'],
                          gender: snapshots.data.docs[index]['petGender'],
                          weight: snapshots.data.docs[index]['petWeight'],
                          color: snapshots.data.docs[index]['petColor'],
                          breed: snapshots.data.docs[index]['petBreed'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToPetDetails(isNew: true),
        child: const Icon(Icons.add),
      ),
    );
  }
}
