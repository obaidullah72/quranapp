import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/chatmodel.dart';
import 'chatscreen.dart';
import 'contactlists.dart';
import 'profile.dart';

class ChatHomeScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatHomeScreen({Key? key}) : super(key: key); // Added constructor

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xff1B202D),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Title and Profile Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Recent Users Label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'R E C E N T',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Recent Users List
            SizedBox(
              height: 110,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('user').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Filter out the current user
                  var recentUsers = snapshot.data!.docs.where((doc) {
                    var user = doc.data() as Map<String, dynamic>;
                    return user['uid'] != currentUserId;
                  }).toList();

                  if (recentUsers.isEmpty) {
                    return const Center(
                      child: Text("No recent users found."),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal, // Make it horizontal
                    itemCount: recentUsers.length,
                    itemBuilder: (context, index) {
                      var user =
                          recentUsers[index].data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                otherUserUid: user['uid'],
                                userName: user['first_name'],
                                userImage: user['url'],
                                userEmail: user['email'],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage:
                                    user['url'] != null && user['url'] != ""
                                        ? NetworkImage(user['url'])
                                        : const AssetImage(
                                                'assets/images/chat111.png')
                                            as ImageProvider,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user['first_name'] ?? 'Unknown User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            // Chat Rooms List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chatrooms')
                      .where('members', arrayContains: currentUserId)
                      .orderBy('lastMessageTimestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('An error occurred: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No chats available'));
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            String chatRoomId = doc.id;
                            String lastMessage =
                                data['lastMessage'] ?? 'No Message';
                            String lastMessageType =
                                data['lastMessageType'] ?? 'text';
                            String profileImageUrl = data['imageUrl'] ?? '';
                            Timestamp? lastMessageTimestamp =
                                data['lastMessageTimestamp'];
                            String formattedTime = '';
                            if (lastMessageTimestamp != null) {
                              DateTime dateTime = lastMessageTimestamp.toDate();
                              formattedTime =
                                  "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
                            }

                            // Safely access the unreadMessages map
                            int unreadCount = (data['unreadMessages']
                                            as Map<String, dynamic>?)
                                        ?.containsKey(currentUserId) ==
                                    true
                                ? data['unreadMessages'][currentUserId] ?? 0
                                : 0;

                            // Determine the other user's ID
                            List<dynamic> members = data['members'] ?? [];
                            String otherUserId = 'Unknown';
                            if (members.length >= 2) {
                              otherUserId = members.firstWhere(
                                (member) => member != currentUserId,
                                orElse: () => 'Unknown',
                              );
                            }

                            // Get the other user's display name
                            Map<String, dynamic>? memberNames =
                                data['memberNames'] != null
                                    ? Map<String, dynamic>.from(
                                        data['memberNames'])
                                    : null;
                            String displayName =
                                memberNames?[otherUserId] ?? 'Unknown';

                            return Dismissible(
                              key: Key(chatRoomId),
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog<bool?>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Chat'),
                                    content: const Text(
                                        'Are you sure you want to delete this chat?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) {
                                deleteChat(chatRoomId);
                              },
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          profileImageUrl.isNotEmpty
                                              ? NetworkImage(profileImageUrl)
                                              : null,
                                      child: profileImageUrl.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  lastMessageType == "img"
                                      ? "[Image]"
                                      : lastMessage,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        otherUserUid: otherUserId,
                                        userName: displayName,
                                        userImage: profileImageUrl,
                                        userEmail: data['memberEmails']
                                                ?[otherUserId] ??
                                            'No Email',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactListScreen()),
            );
          },
          child: const Icon(
            Icons.message,
            color: Colors.white,
          ),
          backgroundColor: const Color(0xff1B202D),
        ),
      ),
    );
  }

  // Show Delete Confirmation Dialog
  Future<bool?> _showDeleteDialog(
      String chatRoomId, BuildContext context) async {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: const Text(
              'Are you sure you want to delete this chat room? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  // Delete Chat Room and Its Messages
  void deleteChat(String chatRoomId) async {
    try {
      // Delete all messages in the chatroom
      QuerySnapshot messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      for (DocumentSnapshot ds in messagesSnapshot.docs) {
        await ds.reference.delete();
      }

      // Delete the chatroom document
      await _firestore.collection('chatrooms').doc(chatRoomId).delete();
    } catch (e) {
      // Handle any errors here
      print("Error deleting chat: $e");
    }
  }
}
