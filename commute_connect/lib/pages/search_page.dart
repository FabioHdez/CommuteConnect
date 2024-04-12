//Dummy search page, where user can look for rides.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:commute_connect/components/my_searchbar.dart';
import 'package:commute_connect/components/my_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final user = FirebaseAuth.instance.currentUser!;

  final TextEditingController searchController = TextEditingController();

  // sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void handleSearch(String address) async {
    Location? coordinates = await convertAddressToCoordinates(address);
    if (coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid destination address')),
      );
      return;
    }
    print('latitude: ${coordinates.latitude} longitude: ${coordinates.longitude}');
    // TODO: SEARCH FOR ANY RIDES AVAILABLE THAT ARE WITHIN THE PICKUP / DROPOFF MARGIN.
    // SEARCH ALL TRIPS
    DatabaseReference tripsRef = FirebaseDatabase.instance.ref().child("trips");
    DatabaseEvent event = await tripsRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (!snapshot.exists) {
      print("No trips found.");
    return;
    } 

    Map<dynamic, dynamic> trips = snapshot.value as Map<dynamic, dynamic>;
    trips.forEach((key, value) async {
      Map trip = value as Map<dynamic, dynamic>;
      

      if (trip.containsKey('fromCoordinates') && trip.containsKey('toCoordinates')){
        List<dynamic> fromCoordinates = trip['fromCoordinates'];
        List<dynamic> toCoordinates = trip['toCoordinates'];
        double fromLat = fromCoordinates[0];
        double fromLng = fromCoordinates[1];
        double toLat = toCoordinates[0];
        double toLng = toCoordinates[1];

        Position? position = await _determinePosition();
        if (position == null) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid destination address')),
          );
        return;
        }

        double distanceFrom = Geolocator.distanceBetween(
          position.latitude, position.longitude, // User's current position
          fromLat, fromLng
          ) / 1609.34; // Convert meters to miles
        double distanceTo = Geolocator.distanceBetween(
        coordinates.latitude, coordinates.longitude,
        toLat, toLng
      ) / 1609.34; // Convert meters to miles

      if (distanceFrom <= trip['pickUpDetourMargin'] && distanceTo <= trip['dropOffDetourMargin']) {
        print('Eligible Trip $key: $value');
      }
      }
    });


    // DRIVER WILL THEN GET A NOTIFICATION THAT A RIDER WANTS TO JOIN THE TRIP
    // DRIVER WILL EITHER ACCEPT OR DECLINE
    // ROUTE WILL THEN ADJUST TO PICK UP THE RIDER
  }

  //geolocation method to get current location
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled; don't continue
      // accessing the position and inform the user.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return null;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied; don't continue
      // accessing the position and inform the user.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are denied')),
      );
      return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever; handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return null;
    }
    // Permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

    //Convert address to Coordinates
  Future<Location?> convertAddressToCoordinates(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      return location;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No coordinates found for this address.'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Error occurred'),
        ),
      );
    print('Error occurred: $e');
  }
    // return a null location
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: Stack(
          children: [
            MyMap(),
            MySearchBar(controller: searchController),
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
                    handleSearch(searchController.text);
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
