//Dummy search page, where user can look for rides.

import 'package:firebase_auth/firebase_auth.dart';
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
    // DRIVER WILL THEN GET A NOTIFICATION THAT A RIDER WANTS TO JOIN THE TRIP
    // DRIVER WILL EITHER ACCEPT OR DECLINE
    // ROUTE WILL THEN ADJUST TO PICK UP THE RIDER
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

  Future<String?> convertCoordinatesToAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "${place.street}, ${place.locality}, ${place.postalCode}";
        return address;
      }
    }catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current position cannot be converted to address')),
      );
    }
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
