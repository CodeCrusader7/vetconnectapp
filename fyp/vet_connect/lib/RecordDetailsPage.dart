import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecordDetailsPage extends StatefulWidget {
  final String recordId;
  final String petId; // Added petId as a required parameter

  RecordDetailsPage({required this.recordId, required this.petId});

  @override
  _RecordDetailsPageState createState() => _RecordDetailsPageState();
}

class _RecordDetailsPageState extends State<RecordDetailsPage> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<QuerySnapshot> _medicalRecordsStream() {
    return FirebaseFirestore.instance
        .collection('medical_records')
        .where('uid', isEqualTo: uid)
        .where('petId', isEqualTo: widget.petId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medical Records')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _medicalRecordsStream(), // Use function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No medical records found.'));
          }

          var records = snapshot.data!.docs;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              var record = records[index];
              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  title: Text(record['recordType'] ?? 'Unknown Type'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Admin Date: ${_formatDate(record['administrationDate'])}'),
                      Text(
                          'Expiry Date: ${_formatDate(record['expirationDate'])}'),
                      if (record['notes'] != null)
                        Text('Notes: ${record['notes']}'),
                      if (record['imageUrl'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Image.network(record['imageUrl'], height: 100),
                        ),
                      if (record['documentPath'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                              '📄 Document: ${record['documentPath'].split('/').last}'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }
}
