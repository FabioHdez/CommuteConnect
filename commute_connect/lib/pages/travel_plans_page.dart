//Dummy travel plans page, where user can see their future travel plans.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TravelPlansPage extends StatelessWidget {
  TravelPlansPage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  // sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
          child: Text(
        "LOGGED IN AS: " + user.email! + "\nThis is the travel plans page",
        style: TextStyle(fontSize: 20),
      )),
    );
  }
}
