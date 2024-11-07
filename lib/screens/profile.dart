import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.black,
          title: Text('Profiles'),
          elevation: 0,
          backgroundColor:
              Colors.white, // Add a color or use the default theme color
        ),
        body: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.0),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .where("uid",
                            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Icon(Icons.error, color: Colors.red);
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No data available'));
                      }
                      var userData = snapshot.data!.docs.first.data();

                      // if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      // var userData = snapshot.data!.docs.first.data();
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: CircleAvatar(
                                backgroundImage: userData['url'] != null &&
                                        userData['url'].isNotEmpty
                                    ? NetworkImage(userData['url'])
                                    : AssetImage('assets/images/chat222.png'),
                                maxRadius: 30,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData['name'] ?? 'Name',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  userData['email'] ?? 'Email',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    // return Container(); // Return empty container if no data
                    ),
              ),
              Divider(
                color: Colors.blueGrey,
                thickness: 1,
              ),
              ListTile(
                onTap: () => _showaccountscreen(context),
                leading: Icon(Icons.key),
                title: Text('Accounts',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text('Security Notifications, Change Numbers',
                    style: TextStyle(fontSize: 12)),
              ),
              ListTile(
                onTap: () => _notificationscreen(context),
                leading: Icon(Icons.notifications_outlined),
                title: Text('Notifications',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text('Message, Groups, Call tones',
                    style: TextStyle(fontSize: 12)),
              ),
              ListTile(
                onTap: () => _showLanguageDrawer(context),
                leading: Icon(Icons.language_outlined),
                title: Text('App Languages',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text('English (device language)',
                    style: TextStyle(fontSize: 12)),
              ),
              ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Help Center',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text('Help Center, Contact Us, Privacy Policy',
                    style: TextStyle(fontSize: 12)),
                onTap: () => _showHelpCenterBottomSheet(context),
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Invite a friend',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                // Add onTap functionality if needed
              ),
              ListTile(
                leading: Icon(Icons.security_update_good_outlined),
                title: Text('App Updates',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () => _showAppUpdatesBottomSheet(context),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return LanguageDrawer();
      },
    );
  }

  void _showHelpCenterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return HelpCenterScreen(); // Convert to a proper widget
      },
    );
  }

  void _showAppUpdatesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AppUpdatesScreen(); // Convert to a proper widget
      },
    );
  }

  void _showaccountscreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AccountsScreen(); // Convert to a proper widget
      },
    );
  }

  void _notificationscreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return NotificationsScreen(); // Convert to a proper widget
      },
    );
  }
}

class AccountsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Center(
        child: ElevatedButton(
          onPressed: () => _showAccountDetailsDialog(context),
          child: Text('Account Settings'),
        ),
      ),
    );
  }

  void _showAccountDetailsDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _fnameController = TextEditingController();
    final _lnameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('user')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('An error occurred. Please try again later.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            }

            if (snapshot.hasData) {
              var userData = snapshot.data?.data();

              if (userData != null) {
                _nameController.text = userData['name'] ?? '';
                _fnameController.text = userData['first_name'] ?? '';
                _lnameController.text = userData['last_name'] ?? '';
                _emailController.text = userData['email'] ?? '';
                _phoneController.text = userData['phone_number'] ?? '';

                return AlertDialog(
                  title: Text('Edit Account Details'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            backgroundImage: userData['imageUrl'] != null &&
                                    userData['imageUrl']!.isNotEmpty
                                ? NetworkImage(userData['imageUrl'])
                                : AssetImage("assets/images/chat222.png")
                                    as ImageProvider,
                            radius: 40,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Username'),
                        ),
                        TextField(
                          controller: _fnameController,
                          decoration: InputDecoration(labelText: 'First Name'),
                        ),
                        TextField(
                          controller: _lnameController,
                          decoration: InputDecoration(labelText: 'Last Name'),
                        ),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                        TextField(
                          controller: _phoneController,
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('user')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .update({
                          'name': _nameController.text,
                          'first_name': _fnameController.text,
                          'last_name': _lnameController.text,
                          'email': _emailController.text,
                          'phone_number': _phoneController.text,
                        })
                            .then((value) {
                          Navigator.of(context).pop();
                        })
                            .catchError((error) {
                          print("Failed to update user: $error");
                        });
                      },
                    ),
                  ],
                );
              } else {
                return AlertDialog(
                  title: Text('No Data'),
                  content: Text('No user data found.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              }
            }
            return Container();
          },
        );
      },
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = true;
  String _selectedRingtone = 'Default Ringtone';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          ListTile(
            title: Text('Select Ringtone'),
            subtitle: Text(_selectedRingtone),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => _showRingtonePicker(context),
          ),
        ],
      ),
    );
  }

  void _showRingtonePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Ringtone'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildRingtoneTile(context, 'Default Ringtone', 'default.mp3'),
                _buildRingtoneTile(context, 'Ringtone 1', 'ringtone1.mp3'),
                _buildRingtoneTile(context, 'Ringtone 2', 'ringtone2.mp3'),
                _buildRingtoneTile(context, 'Ringtone 3', 'ringtone3.mp3'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRingtoneTile(
      BuildContext context, String title, String ringtoneFile) {
    return ListTile(
      title: Text(title),
      onTap: () {
        _audioPlayer.setAsset('assets/ringtones/$ringtoneFile');
        _audioPlayer.play();
        setState(() {
          _selectedRingtone = title;
        });
        Navigator.of(context).pop();
      },
    );
  }
}

class LanguageDrawer extends StatelessWidget {
  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Spanish', 'code': 'es'},
    {'name': 'French', 'code': 'fr'},
    {'name': 'German', 'code': 'de'},
    {'name': 'Chinese', 'code': 'zh'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: 250, // Ensuring the modal sheet is visible
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Language',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(languages[index]['name']!),
                  onTap: () {
                    _selectLanguage(context, languages[index]['code']!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(BuildContext context, String languageCode) {
    // Handle language change here
    print("Language selected: $languageCode");
    Navigator.of(context).pop();
  }
}

class HelpCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Center'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Help Center Content Goes Here',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Contact Us: support@example.com',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              'Privacy Policy: www.example.com/privacy',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class AppUpdatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Updates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Version 2.0.1',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Bug fixes and performance improvements.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              'Visit www.example.com/updates for more details.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
