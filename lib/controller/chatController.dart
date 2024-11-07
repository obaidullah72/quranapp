// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../model/chatmodel.dart';
// import '../model/chatroom.dart';
//
// class ChatController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   var recentUsers = <ChatUser>[].obs;
//   var chatRooms = <ChatRoom>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchRecentUsers();
//     fetchChatRoomsStream();
//   }
//
//   void fetchRecentUsers() async {
//     try {
//       final usersSnapshot = await _firestore.collection('user').get();
//
//       if (usersSnapshot.docs.isEmpty) {
//         print('No users found.');
//         return;
//       }
//
//       List<ChatUser> users = usersSnapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return ChatUser(
//           name: data['first_name'] ?? 'Unknown User',
//           email: data['email'] ?? 'Unknown Email',
//           imagePath: data['url'] ?? '',
//           lastMessage: '',
//           lastMessageTime: '',
//         );
//       }).toList();
//
//       recentUsers.assignAll(users);
//     } catch (e) {
//       print('Error fetching users: $e');
//     }
//   }
//
//   void fetchChatRoomsStream() {
//     final currentUser = _auth.currentUser;
//
//     if (currentUser == null) {
//       print("No user is logged in.");
//       return;
//     }
//
//     final userId = currentUser.uid;
//
//     // Use bindStream to automatically update chatRooms
//     _firestore
//         .collection('user')
//         .doc()
//         .collection('chatrooms')
//         .where('members', arrayContains: {'uid': userId})
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//
//                 final List<dynamic> members = data['members'];
//                 Map<String, dynamic>? otherUser;
//                 print("members ${members}");
//                 for (var member in members) {
//                   if (member['uid'] != userId) {
//                     otherUser = member as Map<String, dynamic>;
//                     break;
//                   }
//                 }
//                 print("Other User ${otherUser}");
//                 if (otherUser == null) {
//                   return null;
//                 }
//
//                 return ChatRoom(
//                   uid: doc.id,
//                   name: otherUser['name'] ?? 'Unknown User',
//                   email: otherUser['email'] ?? 'Unknown Email',
//                   imagePath: otherUser['image'] ?? '',
//                   lastMessage: data['lastMessage'] ?? 'No recent message',
//                   lastMessageTime: data['lastMessageTime'] != null
//                       ? DateFormat('h:mm a').format(
//                           (data['lastMessageTime'] as Timestamp).toDate())
//                       : 'No recent message',
//                   messageCounter:
//                       Map<String, int>.from(data['messageCounter'] ?? {}),
//                 );
//               })
//               .whereType<ChatRoom>()
//               .toList();
//         })
//         .listen((rooms) {
//           chatRooms.assignAll(rooms); // Update the chatRooms observable
//           print("Updated chatRooms: ${chatRooms.length}");
//         });
//   }
//
//   // void fetchChatRoomsStream() {
//   //   final currentUser = _auth.currentUser;
//   //   final userId = currentUser?.uid;
//   //
//   //   if (currentUser == null) {
//   //     print("No user is logged in");
//   //     return;
//   //   } else {
//   //     print("Logged in user ID: ${currentUser.uid}");
//   //   }
//   //
//   //   _firestore.collection('chatrooms').get().then((snapshot) {
//   //     snapshot.docs.forEach((doc) {
//   //       print(doc.data());
//   //     });
//   //   });
//   //
//   //   _firestore
//   //       .collection('chatrooms')
//   //       .where('members', arrayContains: userId)
//   //       .snapshots()
//   //       .listen((snapshot) {
//   //     List<ChatRoom> rooms = snapshot.docs.map((doc) {
//   //       final data = doc.data();
//   //       final members = List.from(data['members'] ?? []);
//   //
//   //       final otherUser = members.firstWhere(
//   //             (member) => member['uid'] != userId,
//   //         orElse: () => {},
//   //       );
//   //
//   //       return ChatRoom(
//   //         uid: doc.id,
//   //         name: otherUser['name'] ?? 'Unknown User',
//   //         email: otherUser['email'] ?? 'Unknown Email',
//   //         imagePath: otherUser['image'] ?? '',
//   //         lastMessage: data['lastMessage'] ?? 'No recent message',
//   //         lastMessageTime: data['lastMessageTime'] != null
//   //             ? DateFormat('h:mm a').format(
//   //             (data['lastMessageTime'] as Timestamp).toDate())
//   //             : 'No recent message',
//   //         messageCounter: Map<String, int>.from(data['messageCounter'] ?? {}),
//   //       );
//   //     }).toList();
//   //
//   //     chatRooms.assignAll(rooms);
//   //   });
//   // }
//
//   void deleteChatRoom(String chatRoomId) async {
//     try {
//       await _firestore.collection('chatrooms').doc(chatRoomId).delete();
//       Get.snackbar('Success', 'Chat room deleted successfully!');
//     } catch (e) {
//       print('Error deleting chat room: $e');
//       Get.snackbar('Error', 'Failed to delete chat room.');
//     }
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../model/chatmodel.dart';

class ChatController extends GetxController {
  RxList<ChatUser> chatRooms = <ChatUser>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchChatRooms();
  }

  void fetchChatRooms() {
    final currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('chatRooms')
        .where('participants', arrayContains: currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      chatRooms.clear();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        chatRooms.add(
          ChatUser(
            uid: doc.id,
            name: data['name'] ?? 'Unknown',
            email: data['email'] ?? '',
            imagePath: data['imagePath'] ?? '',
            lastMessage: data['lastMessage'] ?? '',
            lastMessageTime: data['lastMessageTime'] ?? '',
          ),
        );
      }
    });
  }

  void deleteChatRoom(String chatRoomId) {
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .delete();
  }
}
