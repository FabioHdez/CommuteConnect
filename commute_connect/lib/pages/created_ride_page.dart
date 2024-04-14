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
        showConfirmationBottomSheet(context, trip);

        //prompt driver for confirmation
        //IF NOT CONFIRMED DELETE PASSENGER AND REDUCE PASSENGER INDEX
        //'passengerIndex': ServerValue.increment(-1), CHECK IF THIS WORKS

      }
    });
}
void showConfirmationBottomSheet(BuildContext context, Map<dynamic, dynamic> trip) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(20),
        height: 250, // Adjust height based on your content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Passenger Request 🙋‍♂️',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Passenger: ${trip['passenger${trip['passengerIndex']}']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Pickup Detour: ${trip['pickUpDetourMargin']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Dropoff Detour: ${trip['dropOffDetourMargin']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                    // Handle trip acceptance here
                    print("Trip accepted.");
                    DatabaseReference tripRef = FirebaseDatabase.instance.ref().child("trips/${widget.tripID}");
                    tripRef.update({
                      'pending': false,
                    });
                    //TODO REROUTE THE MAP IF WE FIND A WAY TO ADD STOPS TO THE ROUTE
                  },
                  child: Text('Accept', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                    // Handle trip rejection here
                    print("Trip rejected.");
                    DatabaseReference tripRef = FirebaseDatabase.instance.ref().child("trips/${widget.tripID}");
                    tripRef.child('passenger${trip['passengerIndex']}').remove();
                    tripRef.update({
                      'pending': false, // Reset the pending status
                      'passengerIndex': ServerValue.increment(-1),
                    });
                    
                  },
                  child: Text('Decline', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
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
