import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListOfPetsWithAppointmentPage extends StatelessWidget {
  final String vetId;

  const ListOfPetsWithAppointmentPage({super.key, required this.vetId});

  Future<void> _storeConfirmedAppointments(
      List<Map<String, dynamic>> petsList) async {
    try {
      await FirebaseFirestore.instance
          .collection('vets')
          .doc(vetId)
          .update({'confirmedAppointments': petsList});
    } catch (e) {
      print("Error storing confirmed appointments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pets with Confirmed Appointments"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('vetId', isEqualTo: vetId)
            .where('status',
                isEqualTo: 'confirmed') // Filter only confirmed ones
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No confirmed appointments found"));
          }

          final appointments = snapshot.data!.docs;

          // Prepare list of confirmed pets
          final List<Map<String, dynamic>> confirmedPets =
              appointments.map((appointment) {
            return {
              'petName': appointment['petName'],
              'petOwner': appointment['petOwner'],
            };
          }).toList();

          // Store confirmed pets list in Firestore
          _storeConfirmedAppointments(confirmedPets);

          return ListView.builder(
            itemCount: confirmedPets.length,
            itemBuilder: (context, index) {
              final pet = confirmedPets[index];
              return ListTile(
                title: Text(pet['petName']),
                subtitle: Text("Owner: ${pet['petOwner']}"),
                leading: const Icon(Icons.pets),
              );
            },
          );
        },
      ),
    );
  }
}
