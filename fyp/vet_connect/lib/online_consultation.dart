import 'package:flutter/material.dart';
import 'selectvettochat.dart';

class OnlineConsultationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Online Consultation"),
      ),
      body: Center(
        child: Text("Consult with your selected vets online"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectVetToChatPage()),
          );
        },
        child: Icon(Icons.chat),
        tooltip: 'New Chat',
      ),
    );
  }
}
