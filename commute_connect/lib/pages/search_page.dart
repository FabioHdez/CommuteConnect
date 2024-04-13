//Dummy search page, where user can look for rides.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:commute_connect/components/my_searchbar.dart';
import 'package:commute_connect/components/my_map.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  // sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: Stack(
          children: [
            MyMap(),

            // FlutterMap(
            //     options: MapOptions(
            //         initialCenter: LatLng(25.758091, -80.371587),
            //         initialZoom: 15),
            //     children: [
            //       TileLayer(
            //         urlTemplate:
            //             'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            //         userAgentPackageName: 'com.example.app',
            //       )
            //     ]),
            MySearchBar(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(
                    64), // Optional padding for better appearance
                child: ElevatedButton(
                  onPressed: () {
                    // Your button tap functionality here
                    print('Button tapped!');
                  },
                  child: const Text(
                    'Search for Rides 🔍',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
