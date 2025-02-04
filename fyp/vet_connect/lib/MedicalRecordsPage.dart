import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'RecordDetailsPage.dart';

class MedicalRecordsPage extends StatefulWidget {
  final String petId; // Receive petId from previous page

  MedicalRecordsPage({required this.petId});

  @override
  _MedicalRecordsPageState createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime? administrationDate;
  DateTime? expirationDate;
  XFile? selectedPhoto;
  String? selectedDocument;
  String? recordType;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onDateSelected) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  Future<void> _pickPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedPhoto =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedPhoto != null) {
      setState(() {
        selectedPhoto = pickedPhoto;
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedDocument = result.files.single.path;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<String?> _uploadImageToStorage(XFile imageFile) async {
    try {
      String fileName =
          'medical_records/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(File(imageFile.path));
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      String recordId =
          FirebaseFirestore.instance.collection('medical_records').doc().id;
      String? imageUrl;
      if (selectedPhoto != null) {
        imageUrl = await _uploadImageToStorage(selectedPhoto!);
      }

      await FirebaseFirestore.instance
          .collection('medical_records')
          .doc(recordId)
          .set({
        'id': recordId,
        'petId': widget.petId,
        'uid': uid,
        'recordType': recordType,
        'administrationDate': administrationDate?.toIso8601String(),
        'expirationDate': expirationDate?.toIso8601String(),
        'notes': _notesController.text,
        'imageUrl': imageUrl,
        'documentPath': selectedDocument,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecordDetailsPage(
            recordId: recordId,
            petId: '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Record'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Record Type',
                  suffixIcon: Icon(Icons.arrow_forward_ios,
                      size: 16, color: theme.primaryColor),
                ),
                value: recordType,
                items: [
                  DropdownMenuItem(
                      value: 'Vaccination', child: Text('Vaccination')),
                  DropdownMenuItem(
                      value: 'Deworming', child: Text('Deworming')),
                  DropdownMenuItem(
                      value: 'Flea & Tick Treatment',
                      child: Text('Flea & Tick Treatment')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => recordType = value),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Administration Date',
                  suffixIcon:
                      Icon(Icons.calendar_today, color: theme.primaryColor),
                ),
                controller: TextEditingController(
                    text: _formatDate(administrationDate)),
                readOnly: true,
                onTap: () => _selectDate(context,
                    (date) => setState(() => administrationDate = date)),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Expiration Date',
                  suffixIcon:
                      Icon(Icons.calendar_today, color: theme.primaryColor),
                ),
                controller:
                    TextEditingController(text: _formatDate(expirationDate)),
                readOnly: true,
                onTap: () => _selectDate(
                    context, (date) => setState(() => expirationDate = date)),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Add Files',
                style: theme.textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickPhoto,
                    icon: Icon(Icons.photo_camera),
                    label: Text('Photo'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickDocument,
                    icon: Icon(Icons.insert_drive_file),
                    label: Text('Document'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
              if (selectedPhoto != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Selected Photo: ${selectedPhoto!.name}',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                ),
              if (selectedDocument != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Selected Document: ${selectedDocument!.split('/').last}',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecord,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
