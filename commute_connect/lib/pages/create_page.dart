//Dummy create page, where user can create their own rides.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:commute_connect/pages/created_ride_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class CreatePage extends StatefulWidget {
  final Function(int) onNavigate;
  CreatePage({super.key, required this.onNavigate});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final user = FirebaseAuth.instance.currentUser!;

  // sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // get user vehicles and create a list of vehicles
  final userVehicles = ["Nissan", "Honda", "Toyota"];

  final _formKey = GlobalKey<FormState>();
  String vehicle = "Nissan";
  String destination = "";
  double pickupDetourMargin = 0.0;
  double dropOffDetourMargin = 0.0;
  bool agreement = false;

  // Firebase database instance
  FirebaseDatabase database = FirebaseDatabase.instance;

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
      print('Latitude: ${location.latitude}, Longitude: ${location.longitude}');
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create a new ride session",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField(
                    value: vehicle,
                    onChanged: (String? newValue) {
                      setState(() {
                        vehicle = newValue!;
                      });
                    },
                    items: userVehicles
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Vehicle',
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Destination'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a destination';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      destination = value!;
                    },
                  ),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Pick Up Detour Margin (miles)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      pickupDetourMargin = double.parse(value!);
                    },
                  ),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Drop Off Detour Margin (miles)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      dropOffDetourMargin = double.parse(value!);
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: agreement,
                        onChanged: (bool? value) {
                          setState(() {
                            agreement = value!;
                          });
                        },
                      ),
                      Text('Agree to terms and conditions'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        
                        // button tap functionality here
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          
                          //Validate if is not checked
                          if (!agreement) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('You must agree to the terms and conditions')),
                          );  
                          return;
                          }
                          //Validate for location permissions
                          Position? position = await _determinePosition();
                          if (position == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid destination address')),
                            );
                            return;
                            //initialLocation = [position.latitude, position.longitude];
                          }
                          // Validate for destination address
                          Location? destinationCoordinates = await convertAddressToCoordinates(destination);
                          if (destinationCoordinates == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid destination address')),
                            );
                          return;
                          }
                          LatLng? finalLocation = LatLng(destinationCoordinates.latitude, destinationCoordinates.longitude);


                          // Validate for current address
                          String? currentAddress = await convertCoordinatesToAddress(position);
                          if (currentAddress == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid current address')),
                            );
                          return;
                          }

                          
                          DatabaseReference ref = FirebaseDatabase.instance.ref().child("user/${user.uid}/ride");
                          DatabaseReference newUserRideRef = ref.push();
                          String tripKey = newUserRideRef.key.toString();
                          await newUserRideRef.set({
                            "date_new": DateTime.now().millisecondsSinceEpoch,
                            "date_past": DateTime.now().millisecondsSinceEpoch * -1,
                            "from": currentAddress,
                            "fromCoordinates": [position.latitude, position.longitude],
                            "key": tripKey,
                            "to": destination,
                            "toCoordinates": [destinationCoordinates.latitude, destinationCoordinates.longitude],
                          });
                          DatabaseReference newTripRef = FirebaseDatabase.instance.ref().child("trips/$tripKey");
                          await newTripRef.set({
                            "car_details": vehicle,
                            "pickUpDetourMargin": pickupDetourMargin,
                            "dropOffDetourMargin": dropOffDetourMargin,
                            "driver": user.uid,
                            "from": currentAddress,
                            "fromCoordinates": [position.latitude, position.longitude],
                            "to": destination,
                            "toCoordinates": [destinationCoordinates.latitude, destinationCoordinates.longitude],
                            "pending": false,
                            "passengerIndex": 0
                          });
                          //redirect to gps page
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatedRidePage(finalLocation: finalLocation,tripID: tripKey),
                          ),
                        );
                        }
                        // If the form is valid, display a Snackbar.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ride created')),
                        );

                        // widget.onNavigate(0);
                        
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: const Text(
                        'Create ride session 🚘',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
