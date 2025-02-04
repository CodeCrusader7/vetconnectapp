// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:vet_connect/ChatScreenVet.dart';

// class ChatScreenForVets extends StatefulWidget {
//   const ChatScreenForVets({super.key});

//   @override
//   _ChatScreenForVetsState createState() => _ChatScreenForVetsState();
// }

// class _ChatScreenForVetsState extends State<ChatScreenForVets> {
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   List<Map<String, dynamic>> petsList = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchPets();
//   }

//   Future<void> _fetchPets() async {
//     if (currentUser == null) return;

//     QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
//         .collection('appointments')
//         .where('vetId', isEqualTo: currentUser!.uid)
//         .get();

//     List<String> petIds = appointmentsSnapshot.docs
//         .map((doc) => doc['petId'] as String)
//         .toSet()
//         .toList(); // Unique pets only

//     List<Map<String, dynamic>> fetchedPets = [];

//     for (String petId in petIds) {
//       DocumentSnapshot petDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(petId)
//           .get();

//       if (petDoc.exists) {
//         fetchedPets.add({
//           'id': petDoc.id,
//           'name': petDoc['name'],
//           'profileImage': petDoc['profileImage'] ?? '',
//         });
//       }
//     }

//     setState(() {
//       petsList = fetchedPets;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Chat with Pets")),
//       body: petsList.isEmpty
//           ? const Center(child: Text("No pets found."))
//           : ListView.builder(
//               itemCount: petsList.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage: petsList[index]['profileImage'].isNotEmpty
//                         ? NetworkImage(petsList[index]['profileImage'])
//                         : const AssetImage('assets/default_pet_image.png')
//                             as ImageProvider,
//                   ),
//                   title: Text(petsList[index]['name']),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatScreenVet(
//                           petId: petsList[index]['id'],
//                           petName: petsList[index]['name'],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//     );
//   }
// }
