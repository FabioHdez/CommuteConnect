import 'package:commute_connect/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserModel {
  final String username;
  final String bio;
  final String profileImageUrl;

  UserModel({required this.username, required this.bio, required this.profileImageUrl});

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      username: map['username'] as String? ?? 'No username',
      bio: map['bio'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String? ?? 'https://t3.ftcdn.net/jpg/05/71/08/24/360_F_571082432_Qq45LQGlZsuby0ZGbrd79aUTSQikgcgc.jpg',
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

 Stream<UserModel> getUserProfileStream() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw FirebaseAuthException(code: 'NO_USER', message: 'No user logged in.');
  }
  return FirebaseDatabase.instance.ref('user/${user.uid}')
      .onValue
      .map((event) {
        final snapshot = event.snapshot;
        if (snapshot.exists && snapshot.value is Map) {
          final Map<dynamic, dynamic> userMap = snapshot.value as Map<dynamic, dynamic>;
          return UserModel.fromMap(userMap);
        } else {
          throw Exception('User data is not available or in unexpected format.');
        }
      });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text( "User Profile",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

      ),
      body: StreamBuilder<UserModel>(
        stream: getUserProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No user data found."));
          }
          UserModel user = snapshot.data!;
          return ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              CircleAvatar(
  radius: 80,
  backgroundColor: Colors.grey.shade800,
  child: ClipOval(
    child: FadeInImage.assetNetwork(
      placeholder: 'lib/images/r4p9j6ko.bmp', // Local asset path for placeholder
      image: user.profileImageUrl,
      fit: BoxFit.cover,
      width: 160, // Double the radius for full coverage
      height: 160, // Double the radius for full coverage
      fadeInDuration: Duration(milliseconds: 200),
      placeholderFit: BoxFit.cover,
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.asset('lib/images/r4p9j6ko.bmp', fit: BoxFit.cover); // Fallback to placeholder if error
      },
    ),
  ),
),

        
              const SizedBox(height: 20),
              Center(
                child: Text(
                  user.username,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Center(
                child: Text(
                  user.bio,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('Payment Methods'),
                onTap: () {
                  // Handle navigation
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('Travel History'),
                onTap: () {
                  // Handle navigation
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help'),
                onTap: () {
                  // Handle navigation
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Edit Profile'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
