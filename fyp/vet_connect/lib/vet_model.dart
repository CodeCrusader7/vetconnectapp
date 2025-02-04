class VetModel {
  String id;
  String userId; // Store UID
  String name;
  String description;
  String address;
  String openingTime;
  String closingTime;
  List<String> timeSlots; // Added for time slots
  String website;
  String phone;
  String email;
  String imagePath; // Local image path
  String imageUrl; // Firestore image URL
  bool isEmergencyAvailable;
  double fee;

  VetModel({
    this.id = '',
    this.userId = '',
    required this.name,
    required this.description,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.timeSlots,
    required this.website,
    required this.phone,
    required this.email,
    required this.imagePath,
    required this.imageUrl,
    required this.isEmergencyAvailable,
    this.fee = 0.0,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId, // Store the UID
      'name': name,
      'description': description,
      'address': address,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'timeSlots': timeSlots, // Save time slots
      'website': website,
      'phone': phone,
      'email': email,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'isEmergencyAvailable': isEmergencyAvailable,
      'fee': fee,
    };
  }

  // Convert from JSON (Firestore)
  factory VetModel.fromJson(Map<String, dynamic> json) {
    return VetModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      timeSlots: List<String>.from(json['timeSlots'] ?? []),
      website: json['website'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      imagePath: json['imagePath'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isEmergencyAvailable: json['isEmergencyAvailable'] ?? false,
      fee: (json['fee'] ?? 0.0).toDouble(),
    );
  }
}
