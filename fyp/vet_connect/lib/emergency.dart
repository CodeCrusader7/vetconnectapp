import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Vets'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vets')
            .where('isEmergencyAvailable', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No emergency vets available.'));
          }

          var vets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vets.length,
            itemBuilder: (context, index) {
              var vet = vets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: vet
                    ['photo_url'] != null
                        ? NetworkImage(vet['photo_url'])
                        : null,
                    child: vet['photo_url'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(vet['name'] ?? 'Unknown Vet'),
                  subtitle: Text(vet['clinic_name'] ?? 'No clinic info'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Handle contact action, e.g., call or chat
                      _contactVet(context, vet['contact']);
                    },
                    child: const Text('Contact Now'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _contactVet(BuildContext context, String? contact) {
    if (contact != null && contact.isNotEmpty) {
      // Implement your contact logic, e.g., launch a call or open chat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contacting $contact')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact information not available.')),
      );
    }
  }
}
