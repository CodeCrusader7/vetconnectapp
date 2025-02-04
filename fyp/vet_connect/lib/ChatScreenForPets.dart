// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'chat_screen.dart';

// class ChatScreenForPets extends StatefulWidget {
//   const ChatScreenForPets({super.key});

//   @override
//   _ChatScreenForPetsState createState() => _ChatScreenForPetsState();
// }

// class _ChatScreenForPetsState extends State<ChatScreenForPets> {
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   List<Map<String, dynamic>> vetsList = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchVets();
//   }

//   Future<void> _fetchVets() async {
//     if (currentUser == null) return;

//     QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
//         .collection('appointments')
//         .where('petId', isEqualTo: currentUser!.uid)
//         .get();

//     List<String> vetIds = appointmentsSnapshot.docs
//         .map((doc) => doc['vetId'] as String)
//         .toSet()
//         .toList(); // Unique vets only

//     List<Map<String, dynamic>> fetchedVets = [];

//     for (String vetId in vetIds) {
//       DocumentSnapshot vetDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(vetId)
//           .get();

//       if (vetDoc.exists) {
//         fetchedVets.add({
//           'id': vetDoc.id,
//           'name': vetDoc['name'],
//           'profileImage': vetDoc['profileImage'] ?? '',
//         });
//       }
//     }

//     setState(() {
//       vetsList = fetchedVets;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Chat with Vets")),
//       body: vetsList.isEmpty
//           ? const Center(child: Text("No vets found."))
//           : ListView.builder(
//               itemCount: vetsList.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage: vetsList[index]['profileImage'].isNotEmpty
//                         ? NetworkImage(vetsList[index]['profileImage'])
//                         : const AssetImage('assets/default_vet_image.png')
//                             as ImageProvider,
//                   ),
//                   title: Text(vetsList[index]['name']),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatScreen(
//                           vetId: vetsList[index]['id'],
//                           vetName: vetsList[index]['name'],
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
