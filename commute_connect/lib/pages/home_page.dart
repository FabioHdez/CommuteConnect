//Homepage, user is logged in.

import 'package:commute_connect/pages/create_page.dart';
import 'package:commute_connect/pages/profile_page.dart';
import 'package:commute_connect/pages/search_page.dart';
import 'package:commute_connect/pages/travel_plans_page.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final user = FirebaseAuth.instance.currentUser!;

  // sign user out
  //void signUserOut() {
  //  FirebaseAuth.instance.signOut();
  //}

  int currentIndex = 0;

  void goToPage(index) {
    setState(() {
      currentIndex = index;
    });
  }
  late final List<Widget> _pages;
  @override
  void initState(){
    super.initState();
    _pages = [
    // dummy search page
    SearchPage(),

    // dummy create page
    CreatePage(onNavigate: (index){
      goToPage(index);
    }),

    // dummy travel plans page
    TravelPlansPage(),

    // dummy profile page
    ProfilePage(),
  ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[300],
      //appBar: AppBar(
      //  backgroundColor: Colors.grey[300],
      //  actions: [
      //    IconButton(
      //      onPressed: signUserOut,
      //      icon: const Icon(Icons.logout),
      //    )
      //  ],
      //),
      body: _pages[currentIndex],
      //Center(
      //    child: Text(
      //  "LOGGED IN AS: ${user.email!}",
      //  style: const TextStyle(fontSize: 20),
      //)),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
            onTabChange: (index) => goToPage(index),
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(icon: Icons.search, text: 'Search'),
              GButton(icon: Icons.add_circle_outline, text: 'Create'),
              GButton(icon: Icons.map_outlined, text: 'Travel Plans'),
              GButton(icon: Icons.account_circle_outlined, text: 'Profile')
            ],
          ),
        ),
      ),
    );
  }
}
