import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:commute_connect/components/my_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class CreatedRidePage extends StatefulWidget {
  final LatLng? finalLocation;
  final String tripID;

  CreatedRidePage({
    super.key,
    required this.finalLocation,
    required this.tripID
  });

  @override
  State<CreatedRidePage> createState() => _CreatedRidePageState();
}

class _CreatedRidePageState extends State<CreatedRidePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    monitorTripUpdates();
  }
  void monitorTripUpdates() {
    print("objectasd ${widget.tripID}");
  FirebaseDatabase.instance.ref().child('trips').child(widget.tripID).child('pending')
    .onValue.listen((event) async{
      final data = event.snapshot.value;
      if (data == true) {
        print("There has been a request");
        DatabaseReference tripRef = FirebaseDatabase.instance.ref().child("trips").child(widget.tripID);
        DatabaseEvent event = await tripRef.once();
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic> trip = snapshot.value as Map<dynamic, dynamic>;
        
  
        print("the user is: ${trip['passenger${trip['passengerIndex']}']}");

        //prompt driver for confirmation
        //IF NOT CONFIRMED DELETE PASSENGER AND REDUCE PASSENGER INDEX
        //'passengerIndex': ServerValue.increment(-1), CHECK IF THIS WORKS

      }
    });
}

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
