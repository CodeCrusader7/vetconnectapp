import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnlinePaymentPage extends StatelessWidget {
  final String vetName;
  final DateTime dateTime;
  final int fee;
  final String appointmentId;

  OnlinePaymentPage({
    required this.vetName,
    required this.dateTime,
    required this.fee,
    required this.appointmentId,
  });
  
  get context => null;

  Future<void> _completePayment(String method) async {
    // Update the payment status to "Paid" and specify the payment method
    await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update({
      'paymentStatus': 'Paid',
      'paymentMethod': method,
    });

    // Notify user that payment was successful
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Successful"),
        content: const Text("Your payment has been processed, and the appointment is confirmed."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Online Payment"),
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
            Text("Select Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completePayment("Credit/Debit Card"),
              child: const Text("Credit/Debit Card"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completePayment("JazzCash"),
              child: const Text("JazzCash"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completePayment("EasyPaisa"),
              child: const Text("EasyPaisa"),
            ),
          ],
        ),
      ),
    );
  }
}
