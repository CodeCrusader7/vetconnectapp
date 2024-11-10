import 'package:flutter/material.dart';
import 'package:vet_connect/PetListPage.dart';
import 'package:vet_connect/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vet_connect/appointment_schedules.dart';
import 'package:vet_connect/emergency.dart';
import 'package:vet_connect/online_consultation.dart';
import 'vet_profile_page.dart';
import 'vet_model.dart';

class HomePageForPets extends StatefulWidget {
  const HomePageForPets({super.key});

  @override
  _HomePageForPetsState createState() => _HomePageForPetsState();
}

class _HomePageForPetsState extends State<HomePageForPets> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to fetch vets data from Firestore
  Stream<List<VetModel>> _fetchVets() {
    return _firestore.collection('vets').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) {
          var vet = VetModel.fromJson(doc.data());
          vet.id = doc.id; // Assign document ID to vet for updates/deletions
          return vet;
        }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VetConnect'),
      ),
      drawer: MyDrawer(
        email: "user@example.com", // Replace with dynamic data
        profileImageUrl: "https://www.example.com/profile.jpg",
        onLogout: () {}, // Replace with dynamic data
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.orange.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Take care of pet\'s health\nyour pet is important',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildCategoryButtons(context),
          const SizedBox(height: 16),
          const Text(
            'Veterinary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<VetModel>>(
            stream: _fetchVets(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Failed to load vets.'));
              }

              final vets = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: vets.length,
                itemBuilder: (context, index) {
                  return _buildVeterinaryCard(context, vets[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryButton(
            context,
            Icons.schedule,
            'appointment\nschedules',
            AppointmentSchedulesPage(),
          ),
          const SizedBox(width: 10),
          _buildCategoryButton(
            context,
            Icons.chat,
            'online\nconsultation',
            OnlineConsultationPage(),
          ),
           const SizedBox(width: 10),
                    _buildCategoryButton(
                      context,
                      Icons.pets,
                      'pet\nprofiles',
                      PetListPage(),
                    ),
          const SizedBox(width: 10),
          _buildCategoryButton(
            context,
            Icons.local_hospital,
            'emergency \nservices',
            EmergencyPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            },
            iconSize: 50,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVeterinaryCard(BuildContext context, VetModel vet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VetProfilePage(
              vet: vet,
              onUpdate: (updatedVet) async {
                await _firestore.collection('vets').doc(vet.id).update(updatedVet.toJson());
              },
              onBookAppointment: () {},
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade100, Colors.purple.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ClipOval(
                child: vet.imagePath.isNotEmpty
                    ? Image.network(
                        vet.imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/default_vet_image.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dr. ${vet.name}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    vet.address,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
