import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:commute_connect/components/my_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreatedRidePage extends StatefulWidget {
  final LatLng? finalLocation;
  CreatedRidePage({
    super.key,
    required this.finalLocation
  });

  @override
  State<CreatedRidePage> createState() => _CreatedRidePageState();
}

class _CreatedRidePageState extends State<CreatedRidePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Ongoing Trip...",
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            MyMap(finalLocation: widget.finalLocation),
          ],
        ));
  }
}
