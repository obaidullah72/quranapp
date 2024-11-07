import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatscreen.dart';

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Select Contact",style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xff1B202D),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var users = snapshot.data!.docs.where((user) {
            return user['uid'] != currentUser?.uid;
          }).toList();
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['url'] != null && user['url'] != ""
                      ? NetworkImage(user['url'])
                      : AssetImage('assets/images/chat111.png')
                  as ImageProvider,
                ),
                title: Text(
                  user['first_name'] ?? 'Unknown User',
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  user['email'] ?? 'Unknown Email',
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: () {
                  // Navigate to chat screen with selected user
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
              );
            },
          );
        },
      ),
    );
  }
}
