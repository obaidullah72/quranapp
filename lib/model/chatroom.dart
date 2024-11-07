import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatRoom {
  final String uid;
  final String name;
  final String email;
  final String imagePath;
  final String lastMessage;
  final String lastMessageTime;
  final Map<String, dynamic> messageCounter;

  ChatRoom({
    required this.uid,
    required this.name,
    required this.email,
    required this.imagePath,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.messageCounter,
  });

  // Convert a Firestore document to a ChatRoom instance
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      uid: data['uid'] ?? 'No UID',
      name: data['name'] ?? 'Unknown User',
      email: data['email'] ?? 'Unknown Email',
      imagePath: data['image'] ?? '',
      lastMessage: data['lastMessage'] ?? 'No recent message',
      lastMessageTime: data['lastMessageTime'] != null
          ? DateFormat('h:mm a').format((data['lastMessageTime'] as Timestamp).toDate())
          : 'No recent message',
      messageCounter: data['messageCounter'] ?? {'text': 0, 'image': 0}, // Handle messageCounter
    );
  }

  // Convert a ChatRoom instance to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'image': imagePath,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'messageCounter': messageCounter, // Include messageCounter
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoom && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  // Create a copy of the ChatRoom with some updated fields
  ChatRoom copyWith({
    String? uid,
    String? name,
    String? email,
    String? imagePath,
    String? lastMessage,
    String? lastMessageTime,
    Map<String, dynamic>? messageCounter,
  }) {
    return ChatRoom(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      messageCounter: messageCounter ?? this.messageCounter,
    );
  }
}
