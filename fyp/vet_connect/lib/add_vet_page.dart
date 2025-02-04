import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'vet_model.dart';

class AddVetPage extends StatefulWidget {
  final Function(VetModel) onSave;
  final VetModel? vet;

  const AddVetPage({super.key, required this.onSave, this.vet});

  @override
  _AddVetPageState createState() => _AddVetPageState();
}

class _AddVetPageState extends State<AddVetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _feeController;
  File? _selectedImage;
  bool _isEmergencyAvailable = false;
  List<TimeOfDay> selectedSlots = [];
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vet?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.vet?.description ?? '');
    _addressController = TextEditingController(text: widget.vet?.address ?? '');
    _websiteController = TextEditingController(text: widget.vet?.website ?? '');
    _phoneController = TextEditingController(text: widget.vet?.phone ?? '');
    _emailController = TextEditingController(text: widget.vet?.email ?? '');
    _feeController =
        TextEditingController(text: widget.vet?.fee.toString() ?? '');
    _isEmergencyAvailable = widget.vet?.isEmergencyAvailable ?? false;
    _imageUrl = widget.vet?.imagePath ?? null;
  }

  Future<void> _uploadImage(File imageFile, String vetId) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('vet_images/$vetId.jpg');
      await storageRef.putFile(imageFile);
      String imageUrl = await storageRef.getDownloadURL();

      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _saveToFirestore(VetModel vet) async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      if (!mounted) return; // ✅ Check if widget is still in the tree
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated! Please log in.')),
      );
      return;
    }

    final vetId = user.uid;

    try {
      if (_selectedImage != null) {
        await _uploadImage(_selectedImage!, vetId);
      }

      final vetData = vet.toJson();
      vetData['imageUrl'] = _imageUrl ?? '';
      vetData['fee'] = int.tryParse(_feeController.text) ?? 0;
      vetData['availableSlots'] =
          selectedSlots.map((slot) => slot.format(context)).toList();
      vetData['isEmergencyAvailable'] = _isEmergencyAvailable;

      await firestore.collection('vets').doc(vetId).set(vetData);

      if (!mounted)
        return; // ✅ Prevent calling context-related code after unmount
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vet saved successfully!')),
      );
    } catch (e) {
      print('Error saving vet: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save vet. Please try again.')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newVet = VetModel(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        website: _websiteController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        isEmergencyAvailable: _isEmergencyAvailable,
        imagePath: _imageUrl ?? '',
        openingTime: '',
        closingTime: '',
        timeSlots: [],
        imageUrl: '',
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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 10),
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 200)
              else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                Image.network(_imageUrl!, height: 200),
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: 'Website'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _feeController,
                decoration: const InputDecoration(labelText: 'Fee'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Emergency Available',
                      style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _isEmergencyAvailable,
                    activeColor: Colors.green,
                    inactiveTrackColor: Colors.red.shade300,
                    onChanged: (bool value) {
                      setState(() {
                        _isEmergencyAvailable = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Time Slots:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: List.generate(19, (index) {
                  final timeSlot = TimeOfDay(hour: 6 + index, minute: 0);
                  return ChoiceChip(
                    label: Text(timeSlot.format(context)),
                    selected: selectedSlots.contains(timeSlot),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? selectedSlots.add(timeSlot)
                            : selectedSlots.remove(timeSlot);
                      });
                    },
                  );
                }),
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
