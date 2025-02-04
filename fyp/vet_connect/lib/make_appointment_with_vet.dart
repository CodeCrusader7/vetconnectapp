import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vet_connect/home_page_for_pets.dart';

class MakeAppointmentWithVetPage extends StatefulWidget {
  final String vetId;

  const MakeAppointmentWithVetPage({super.key, required this.vetId});

  @override
  _MakeAppointmentWithVetPageState createState() =>
      _MakeAppointmentWithVetPageState();
}

class _MakeAppointmentWithVetPageState
    extends State<MakeAppointmentWithVetPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String vetName = "Loading...";
  int vetFee = 0;
  List<String> availableSlots = [];
  Set<String> bookedSlots = {};

  @override
  void initState() {
    super.initState();
    _fetchVetDetails();
  }

  Future<void> _fetchVetDetails() async {
    try {
      final vetDoc = await FirebaseFirestore.instance
          .collection('vets')
          .doc(widget.vetId)
          .get();

      if (vetDoc.exists) {
        setState(() {
          vetName = 'Dr. ${vetDoc['name'] ?? 'Unknown'}';
          vetFee = vetDoc['fee'] ?? 1000;
          availableSlots = List<String>.from(vetDoc['availableSlots'] ?? []);
        });
      }
    } catch (e) {
      print("Error fetching vet details: $e");
      setState(() {
        vetName = "Error loading vet";
      });
    }
  }

  Future<void> _fetchBookedSlots() async {
    if (selectedDate == null) return;

    try {
      final vetDoc = await FirebaseFirestore.instance
          .collection('vets')
          .doc(widget.vetId)
          .get();

      if (vetDoc.exists) {
        final bookedData = vetDoc['bookedSlots'] ?? {};
        setState(() {
          bookedSlots =
              (bookedData[selectedDate!.toString().split(' ')[0]] ?? [])
                  .cast<String>()
                  .toSet();
        });
      }
    } catch (e) {
      print("Error fetching booked slots: $e");
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        bookedSlots.clear();
      });
      await _fetchBookedSlots();
    }
  }

  Future<void> _confirmAppointment() async {
    if (selectedTime == null || selectedDate == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final String userId = user.uid;
    final String formattedTime = selectedTime!.format(context);
    final String formattedDate = selectedDate!.toString().split(' ')[0];

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final vetDocRef = firestore.collection('vets').doc(widget.vetId);

      await firestore.runTransaction((transaction) async {
        // Fetch vet's current booked slots inside transaction
        final vetDoc = await transaction.get(vetDocRef);
        if (!vetDoc.exists) {
          throw Exception("Vet details not found");
        }

        Map<String, dynamic> bookedData = vetDoc.data()?['bookedSlots'] ?? {};
        List<String> bookedTimes =
            List<String>.from(bookedData[formattedDate] ?? []);

        if (bookedTimes.contains(formattedTime)) {
          throw Exception(
              "This slot is already booked. Please select another.");
        }

        // Add the new booked slot
        bookedTimes.add(formattedTime);
        bookedData[formattedDate] = bookedTimes;

        transaction.update(vetDocRef, {'bookedSlots': bookedData});

        // Save confirmed appointment in Firestore
        final newAppointmentRef = firestore.collection('appointments').doc();
        transaction.set(newAppointmentRef, {
          'appointmentId': newAppointmentRef.id, // Ensure unique ID
          'vetId': widget.vetId,
          'vetName': vetName,
          'date': formattedDate,
          'time': formattedTime,
          'fee': vetFee,
          'uid': userId,
          'status': 'confirmed',
        });
      });

      // ✅ Ensure HomePageForPets refreshes and displays the new appointment
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const HomePageForPets(refresh: true)), // Pass refresh flag
        (route) => false,
      );
    } catch (e) {
      print("Error confirming appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Make Appointment with $vetName"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(vetName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Fee: $vetFee Rs', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectDate,
              child: Text(selectedDate == null
                  ? "Select Date"
                  : selectedDate!.toLocal().toString().split(' ')[0]),
            ),
            const SizedBox(height: 20),
            const Text("Select Time Slot",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: availableSlots.isNotEmpty
                  ? availableSlots.map((slot) {
                      final isBooked = bookedSlots.contains(slot);
                      final isSelected = selectedTime?.format(context) == slot;

                      return ChoiceChip(
                        label: Text(
                          slot,
                          style: TextStyle(
                            color: isBooked ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: isBooked
                            ? null
                            : (_) => setState(() {
                                  selectedTime = _parseTimeOfDay(slot);
                                }),
                        selectedColor: Colors.green,
                        backgroundColor:
                            isBooked ? Colors.red : Colors.grey[300],
                        disabledColor: Colors.red,
                      );
                    }).toList()
                  : [
                      const Text("No available slots",
                          style: TextStyle(fontSize: 16, color: Colors.red))
                    ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: (selectedDate != null && selectedTime != null)
                  ? _confirmAppointment
                  : null,
              child: const Text("Confirm Appointment"),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to convert string to TimeOfDay
  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(":");
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
