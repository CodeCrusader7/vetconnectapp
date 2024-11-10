import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vet_connect/online_payment.dart';

class PaymentOptionsPage extends StatelessWidget {
  final String vetName;
  final DateTime dateTime;
  final int fee;
  final String vetId;
  String? appointmentId;

  PaymentOptionsPage({
    required this.vetName,
    required this.dateTime,
    required this.fee,
    required this.vetId,
  });

  Future<void> _saveAppointment(String paymentMethod, BuildContext context) async {
    final appointmentRef = FirebaseFirestore.instance.collection('appointments').doc();
    
    await appointmentRef.set({
      'vetId': vetId,
      'vetName': vetName,
      'date': dateTime,
      'time': TimeOfDay.fromDateTime(dateTime).format(context),
      'fee': fee,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentMethod == "Pay at Clinic" ? "Confirmed" : "Pending",
    });

    // Store appointment ID for reference
    appointmentId = appointmentRef.id;

    // Navigate to payment page if online, or return if paying at clinic
    if (paymentMethod == "Online Payment") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnlinePaymentPage(
            vetName: vetName,
            dateTime: dateTime,
            fee: fee,
            appointmentId: appointmentId!,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Appointment Confirmed"),
          content: const Text("Your appointment is confirmed. Please pay at the clinic."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Options"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Vet: $vetName", style: TextStyle(fontSize: 20)),
            Text("Appointment Date: ${dateTime.toLocal().toString().split(' ')[0]}"),
            Text("Time: ${TimeOfDay.fromDateTime(dateTime).format(context)}"),
            Text("Fee: $fee Rs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _saveAppointment("Online Payment", context),
              child: const Text("Online Payment"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveAppointment("Pay at Clinic", context),
              child: const Text("Pay at Clinic"),
            ),
          ],
        ),
      ),
    );
  }
}
