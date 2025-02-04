import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vet_connect/view_booked_pets.dart';

class AppointmentsForVetsPage extends StatelessWidget {
  final String vetId;

  const AppointmentsForVetsPage({super.key, required this.vetId});

  Future<List<Map<String, dynamic>>> _fetchConfirmedAppointments() async {
    try {
      QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('vetId', isEqualTo: vetId)
          .where('status',
              isEqualTo: 'confirmed') // Only fetch confirmed appointments
          .get();

      List<Map<String, dynamic>> appointments = [];

      for (var doc in appointmentSnapshot.docs) {
        var appointmentData = doc.data() as Map<String, dynamic>;
        var petId = appointmentData['petId'];
        var date = (appointmentData['date'] as Timestamp)
            .toDate(); // Ensure proper date format
        var timeSlot = appointmentData['time'];

        // Fetch pet details from Firestore
        var petSnapshot = await FirebaseFirestore.instance
            .collection('pets')
            .doc(petId)
            .get();

        if (petSnapshot.exists) {
          var petData = petSnapshot.data() as Map<String, dynamic>;

          // Store appointment details with pet info
          appointments.add({
            'appointmentId': doc.id,
            'appointmentDetails': appointmentData,
            'petDetails': petData,
            'petOwnerEmail': appointmentData['petOwnerEmail'],
          });

          // Update vet's booked slots in Firestore
          await _markTimeSlotAsBooked(date, timeSlot);
        }
      }
      return appointments;
    } catch (e) {
      print("Error fetching confirmed appointments: $e");
      return [];
    }
  }

  // Function to mark a time slot as booked in Firestore
  Future<void> _markTimeSlotAsBooked(DateTime date, String timeSlot) async {
    DocumentReference vetDocRef =
        FirebaseFirestore.instance.collection('vets').doc(vetId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot vetDoc = await transaction.get(vetDocRef);
      if (!vetDoc.exists) return;

      Map<String, dynamic> bookedSlots =
          (vetDoc.data() as Map<String, dynamic>)['bookedSlots'] ?? {};

      String formattedDate = "${date.year}-${date.month}-${date.day}";

      // Ensure structure for bookedSlots
      if (!bookedSlots.containsKey(formattedDate)) {
        bookedSlots[formattedDate] = {};
      }
      bookedSlots[formattedDate][timeSlot] = true; // Mark slot as booked

      transaction.update(vetDocRef, {'bookedSlots': bookedSlots});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmed Appointments")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchConfirmedAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load appointments"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No confirmed appointments"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var appointment = snapshot.data![index];
              var pet = appointment['petDetails'];
              var petOwnerEmail = appointment['petOwnerEmail'];

              return ListTile(
                leading: pet['imageUrl'] != null && pet['imageUrl'].isNotEmpty
                    ? Image.network(
                        pet['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.pets, size: 50),
                title: Text(pet['name'] ?? "Pet"),
                subtitle: Text(
                    'Owner Email: $petOwnerEmail\nCategory: ${pet['category'] ?? "Unknown"}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewBookedPetPage(petId: pet['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
