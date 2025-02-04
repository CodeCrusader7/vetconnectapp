import 'package:flutter/material.dart';
import 'dart:io';

class PetProfilePage extends StatelessWidget {
  final Map<String, String> pet;

  PetProfilePage({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle the pet image properly
            if (pet['imagePath'] != null && pet['imagePath']!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(pet['imagePath']!),
                  width: double.infinity,
                  height: 250, // Increased height for better presentation
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250, // Same as image height for consistency
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pets,
                  size: 100,
                  color: Colors.grey[400],
                ),
              ),
            SizedBox(height: 16),
            Text(
              pet['name'] ?? 'Pet Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              pet['type'] ?? 'Pet Type',
              style: TextStyle(fontSize: 18, color: Colors.purple),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCard('Age', pet['age'] ?? ''),
                _buildInfoCard('Gender', pet['gender'] ?? ''),
                _buildInfoCard('Weight', pet['weight'] ?? ''),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Additional Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildAdditionalInfo('Color', pet['color'] ?? ''),
            _buildAdditionalInfo('Breed', pet['breed'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String info) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.purple),
            ),
            SizedBox(height: 8),
            Text(
              info,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(String title, String info) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            info,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
