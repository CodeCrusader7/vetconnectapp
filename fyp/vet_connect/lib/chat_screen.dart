// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class ChatScreen extends StatefulWidget {
//   final String vetId;
//   final String vetName;

//   const ChatScreen({super.key, required this.vetId, required this.vetName});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImagePicker _picker = ImagePicker();
//   File? _image;

//   Future<void> _sendMessage({String? imageUrl, String? fileUrl}) async {
//     if (_messageController.text.isEmpty && imageUrl == null && fileUrl == null) return;

//     await _firestore.collection('chats').doc(currentUser!.uid).collection(widget.vetId).add({
//       'senderId': currentUser!.uid,
//       'receiverId': widget.vetId,
//       'message': _messageController.text,
//       'imageUrl': imageUrl ?? '',
//       'fileUrl': fileUrl ?? '',
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     _messageController.clear();
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       File imageFile = File(pickedFile.path);
//       setState(() {
//         _image = imageFile;
//       });

//       String imageUrl = await _uploadFile(imageFile, "images");
//       _sendMessage(imageUrl: imageUrl);
//     }
//   }

//   Future<String> _uploadFile(File file, String folder) async {
//     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//     Reference storageRef = FirebaseStorage.instance.ref().child('$folder/$fileName');
//     await storageRef.putFile(file);
//     return await storageRef.getDownloadURL();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chat with ${widget.vetName}")),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('chats')
//                   .doc(currentUser!.uid)
//                   .collection(widget.vetId)
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 var messages = snapshot.data!.docs;

//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     var message = messages[index];
//                     bool isMe = message['senderId'] == currentUser!.uid;

//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.blueAccent : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (message['imageUrl'] != '')
//                               Image.network(message['imageUrl'], width: 200, height: 200),
//                             if (message['fileUrl'] != '')
//                               Text("📄 File sent", style: TextStyle(color: isMe ? Colors.white : Colors.black)),
//                             if (message['message'] != '')
//                               Text(
//                                 message['message'],
//                                 style: TextStyle(color: isMe ? Colors.white : Colors.black),
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.image),
//                   onPressed: _pickImage,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(hintText: "Type a message..."),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () => _sendMessage(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
