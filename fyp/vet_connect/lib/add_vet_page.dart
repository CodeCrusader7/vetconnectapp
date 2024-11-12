import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'vet_model.dart';

class AddVetPage extends StatefulWidget {
  final Function(VetModel) onSave;
  final VetModel? vet;

  const AddVetPage({Key? key, required this.onSave, this.vet}) : super(key: key);

  @override
  _AddVetPageState createState() => _AddVetPageState();
}

class _AddVetPageState extends State<AddVetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _openingTimeController;
  late TextEditingController _closingTimeController;
  late TextEditingController _descriptionController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  File? _selectedImage;
  bool _isEmergencyAvailable = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vet?.name ?? '');
    _descriptionController = TextEditingController(text: widget.vet?.description ?? '');
    _addressController = TextEditingController(text: widget.vet?.address ?? '');
    _openingTimeController = TextEditingController(text: widget.vet?.openingTime ?? '');
    _closingTimeController = TextEditingController(text: widget.vet?.closingTime ?? '');
    _websiteController = TextEditingController(text: widget.vet?.website ?? '');
    _phoneController = TextEditingController(text: widget.vet?.phone ?? '');
    _emailController = TextEditingController(text: widget.vet?.email ?? '');
    _isEmergencyAvailable = widget.vet?.isEmergencyAvailable ?? false;
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('vet_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveToFirestore(VetModel vet) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final imageUrl = _selectedImage != null ? await _uploadImage(_selectedImage!) : null;

      final vetData = vet.toJson();
      if (imageUrl != null) vetData['imageUrl'] = imageUrl;

      await firestore.collection('vets').add(vetData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vet saved successfully!')),
      );
    } catch (e) {
      print('Error saving vet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save vet. Please try again.')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newVet = VetModel(
        id: '', // Firestore will generate an ID
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        openingTime: _openingTimeController.text,
        closingTime: _closingTimeController.text,
        website: _websiteController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        isEmergencyAvailable: _isEmergencyAvailable, imagePath: '',
      );

      _saveToFirestore(newVet);
      widget.onSave(newVet);
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vet == null ? 'Add New Vet' : 'Edit Vet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 200,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _openingTimeController,
                decoration: const InputDecoration(labelText: 'Opening Time'),
                readOnly: true,
                onTap: _pickOpeningTime,
              ),
              TextFormField(
                controller: _closingTimeController,
                decoration: const InputDecoration(labelText: 'Closing Time'),
                readOnly: true,
                onTap: _pickClosingTime,
              ),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: 'Website'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Emergency Available'),
                  Switch(
                    value: _isEmergencyAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isEmergencyAvailable = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.vet == null ? 'Add Vet' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
