import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userImage;
  final String otherUserUid;

  const ChatScreen({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userImage,
    required this.otherUserUid,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? chatRoomId;
  String? currentUserName;
  String? currentUserEmail;
  String? currentUserImage;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadCurrentUserDetails();
    if (currentUserEmail != null) {
      await createOrGetChatRoom();
    } else {
      print(
          "Error: Current user email is null. Unable to proceed with creating or getting chat room.");
    }
  }

  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  Future<void> _loadCurrentUserDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDetails = await getUserDetails(currentUser.uid);
      if (userDetails != null) {
        setState(() {
          currentUserName = userDetails['first_name'];
          currentUserEmail = userDetails['email'];
          currentUserImage = userDetails['url'];
        });
      }
    }
  }

  Future<void> createOrGetChatRoom() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await _loadCurrentUserDetails();

      if (currentUserEmail != null) {
        String generatedChatRoomId =
            _generateChatRoomId(widget.userName, currentUserName!);
        final chatRoomRef = FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(generatedChatRoomId);

        final chatRoomSnapshot = await chatRoomRef.get();

        if (!chatRoomSnapshot.exists) {
          await chatRoomRef.set({
            'chatRoomId': generatedChatRoomId,
            'members': [
              {
                'uid': widget.otherUserUid,
                'name': widget.userName,
                'email': widget.userEmail,
                'image': widget.userImage
              },
              {
                'uid': currentUser.uid,
                'name': currentUserName ?? 'Anonymous',
                'email': currentUserEmail,
                'image': currentUserImage ?? ''
              },
            ],
            'createdAt': FieldValue.serverTimestamp(),
            'lastMessage': '',
            'lastMessageType': 'text',
            'lastMessageTime': '',
            'messageCounter': {'text': 0, 'image': 0},
          });
        }

        setState(() {
          chatRoomId = generatedChatRoomId;
        });
      }
    }
  }

  String _generateChatRoomId(String userA, String userB) {
    return userA.hashCode <= userB.hashCode
        ? '${userA}_$userB'
        : '${userB}_$userA';
  }

  Future<void> sendMessage(String message, String messageType) async {
    if (message.trim().isNotEmpty &&
        chatRoomId != null &&
        currentUserEmail != null) {
      final chatRoomRef =
          FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomId);

      DateTime now = DateTime.now();
      String formattedTime = DateFormat('hh:mm a').format(now);

      await chatRoomRef.collection('chats').add({
        'message': message,
        'sender': currentUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'messageType': messageType,
        'time': formattedTime,
      });

      await chatRoomRef.update({
        'lastMessage': message,
        'lastMessageType': messageType,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'messageCounter.$messageType': FieldValue.increment(1),
      });

      await chatRoomRef.update({
        'userCounters.${widget.otherUserUid}.$messageType':
            FieldValue.increment(1),
        'userCounters.${FirebaseAuth.instance.currentUser!.uid}.$messageType':
            FieldValue.increment(1),
      });

      _messageController.clear();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        // Upload the image to Firebase Storage
        final storageRef =
            FirebaseStorage.instance.ref().child('chat_images/$fileName');
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask;
        final imageUrl = await snapshot.ref.getDownloadURL();

        // Send the image URL as a message
        sendMessage(imageUrl, "image");
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  Future<void> _deleteMessage(
      String messageId, String messageType, String? imageUrl) async {
    final chatRoomRef =
        FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomId);

    try {
      await chatRoomRef.collection('chats').doc(messageId).delete();

      if (messageType == "image" && imageUrl != null) {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  Future<void> _editMessage(String messageId, String newMessage) async {
    final chatRoomRef =
        FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomId);

    try {
      await chatRoomRef.collection('chats').doc(messageId).update({
        'message': newMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error editing message: $e");
    }
  }

  void _showEditDeleteDialog(String messageId, String messageType,
      String? imageUrl, String? currentMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: messageType == "text"
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      child: Text("Edit"),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditTextDialog(messageId, currentMessage!);
                      },
                    ),
                    TextButton(
                      child: Text("Delete"),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteMessage(messageId, messageType, imageUrl);
                      },
                    ),
                  ],
                )
              : TextButton(
                  child: Text("Delete"),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteMessage(messageId, messageType, imageUrl);
                  },
                ),
        );
      },
    );
  }

  void _showEditTextDialog(String messageId, String currentMessage) {
    TextEditingController editController =
        TextEditingController(text: currentMessage);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Message"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: "Edit your message"),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                Navigator.pop(context);
                _editMessage(messageId, editController.text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1B202D),
      body: Padding(
        padding: EdgeInsets.only(left: 14.0, right: 14),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: widget.userImage.isNotEmpty
                        ? NetworkImage(widget.userImage)
                        : AssetImage('assets/images/chat111.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    widget.userName,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Quicksand',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatRoomId != null
                      ? FirebaseFirestore.instance
                          .collection('chatrooms')
                          .doc(chatRoomId)
                          .collection('chats')
                          .orderBy('timestamp', descending: false)
                          .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message, color: Colors.blueGrey, size: 100,
                            ),
                            Text(
                              "No Messages",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final messageDoc = snapshot.data!.docs[index];
                          final messageData =
                              messageDoc.data() as Map<String, dynamic>;
                          final message = messageData['message'];
                          final sender = messageData['sender'];
                          final messageType = messageData['messageType'];
                          final messageId = messageDoc.id;
                          final time = messageData[
                              'time']; // Get the time from the message data
                          bool isCurrentUser = sender == currentUserEmail;

                          return GestureDetector(
                            onLongPress: () {
                              _showEditDeleteDialog(
                                messageId,
                                messageType,
                                messageType == "image" ? message : null,
                                messageType == "text" ? message : null,
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                // Change to Column to stack message and time
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: isCurrentUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (!isCurrentUser)
                                        CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(widget.userImage),
                                        ),
                                      SizedBox(width: 8.0),
                                      messageType == "text"
                                          ? Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: isCurrentUser
                                                    ? Colors.blue
                                                    : Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                message,
                                                style: TextStyle(
                                                  color: isCurrentUser
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullScreenImageViewer(
                                                            imageUrl: message),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 150,
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                    image:
                                                        NetworkImage(message),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      if (isCurrentUser) SizedBox(width: 8.0),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  // Spacing between message and time
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Text(
                                      time, // Display the time below the message
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.image),
                      color: Colors.white,
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter a message...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: () {
                        sendMessage(_messageController.text, "text");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Hero(
            tag: imageUrl, // Add a hero animation tag for smooth transitions
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
