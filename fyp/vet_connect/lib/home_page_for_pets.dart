import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vet_connect/ChatScreenForPets.dart';
import 'package:vet_connect/drawer.dart';
import 'PetListPage.dart';
import 'appointment_schedules.dart';
import 'emergency.dart';
import 'vet_profile_page.dart';
import 'vet_model.dart';
import 'dart:io';

class HomePageForPets extends StatefulWidget {
  final bool refresh;
  const HomePageForPets({Key? key, this.refresh = false}) : super(key: key);

  @override
  _HomePageForPetsState createState() => _HomePageForPetsState();
}

class _HomePageForPetsState extends State<HomePageForPets> {
  List<VetModel> vets = [];
  String userEmail = "Loading...";
  String profileImageUrl = "";
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    if (widget.refresh) {
      _fetchAppointments(); // Refresh appointments on page reload
    }
    _fetchUserData();
    _fetchAppointments(); // Fetch scheduled appointments
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? "No Email Found";
        profileImageUrl = user.photoURL ?? ""; // Default empty if no photo
      });
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    bool confirmCancel = await _showConfirmationDialog();
    if (confirmCancel) {
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .delete();

        setState(() {
          appointments
              .removeWhere((appointment) => appointment['id'] == appointmentId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment canceled successfully!")),
        );
      } catch (e) {
        print("Error canceling appointment: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to cancel appointment.")),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Cancellation"),
            content:
                const Text("Are you sure you want to cancel this appointment?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _fetchAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      FirebaseFirestore.instance
          .collection('appointments')
          .where('uid', isEqualTo: uid)
          .orderBy('date', descending: false)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          appointments = snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            return {
              'id': doc.id, // Ensure document ID is stored
              'vetName': data['vetName']?.toString() ?? 'Unknown',
              'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
              'time': data['time']?.toString() ?? 'Unknown',
            };
          }).toList();
        });
      });
    }
  }

  void _updateVet(int index, VetModel updatedVet) {
    setState(() {
      vets[index] = updatedVet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VetConnect'),
      ),
      drawer: MyDrawer(
        profileImageUrl: profileImageUrl,
        email: '',
        onLogout: () {},
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
          SingleChildScrollView(
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
                  EmergencyPage(),
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
                  const EmergencyPage(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Veterinary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
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
              return _buildVeterinaryCard(context, vets[index], index);
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Scheduled Appointments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          appointments.isEmpty
              ? const Text("No upcoming appointments",
                  style: TextStyle(fontSize: 16, color: Colors.red))
              : Column(
                  children: appointments.map((appointment) {
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          "Dr. ${appointment['vetName']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Date: ${appointment['date'].toString().split(' ')[0]}\nTime: ${appointment['time']}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () =>
                              _cancelAppointment(appointment['id']),
                        ),
                      ),
                    );
                  }).toList(),
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

  Widget _buildVeterinaryCard(BuildContext context, VetModel vet, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VetProfilePage(
              vet: vet,
              onUpdate: (updatedVet) => _updateVet(index, updatedVet),
              onBookAppointment: () {},
              vetId: '',
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
                child:
                    vet.imagePath.isNotEmpty && File(vet.imagePath).existsSync()
                        ? Image.file(
                            File(vet.imagePath),
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
