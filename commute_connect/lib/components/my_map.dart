// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

class MyMap extends StatefulWidget {
  const MyMap({Key? key}) : super(key: key);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late GoogleMapController mapController;
  final Location locationController = Location();
  LatLng currentP = const LatLng(0.0, 0.0);
  LatLng fiu = const LatLng(25.7562, -80.3755);
  LatLng? destinationP;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  // Gets the current locations
  Future<void> getLocationUpdates() async {
    locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          updateMarkers();
          if (destinationP != null) {
            getPolylinePoints();
          }
        });
      }
    });
  }

  // This gets the line for the route
  Future<void> getPolylinePoints() async {
    if (destinationP == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PointLatLng point1 = PointLatLng(currentP.latitude, currentP.longitude);
    PointLatLng point2 =
        PointLatLng(destinationP!.latitude, destinationP!.longitude);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCNle6rymUlDYnphTVfFbwUMIbGFDNd_0A', // Replace with your Google Maps API Key
      point1,
      point2,
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        polylines.clear();
        polylines.add(Polyline(
          polylineId: const PolylineId("poly"),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 8,
        ));
      });
    }
  }

  // The markers that show on the map
  void updateMarkers() {
    if (destinationP == null) return;

    setState(() {
      markers = {
        Marker(
          markerId: const MarkerId("_currentLocation"),
          icon: BitmapDescriptor.defaultMarker,
          position: currentP,
        ),
        Marker(
          markerId: const MarkerId("_destinationLocation"),
          icon: BitmapDescriptor.defaultMarker,
          position: destinationP!,
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: fiu, // Where the map will start off in location
          zoom: 13,
        ),
        markers: markers,
        polylines: polylines,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final LatLng? selectedLocation = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DestinationSelectionScreen()),
          );
          if (selectedLocation != null) {
            setState(() {
              destinationP = selectedLocation;
              markers.clear();
              polylines.clear();
              updateMarkers();
              getPolylinePoints();
            });
          } else {
            setState(() {
              destinationP = null;
              markers.clear();
              polylines.clear();
            });
          }
        },
        mini: true,
        child: Icon(Icons.directions),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.startFloat, // Adjust position here
    );
  }
}

class DestinationSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destinations'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // In a real application, you might use a different mechanism
                // to select the destination, such as a map or a search screen.
                Navigator.pop(context, LatLng(25.758091, -80.371587));
              },
              child: Text('Select Destination'),
            ),

            SizedBox(height: 20), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                print('Clear button pressed'); // Debug print
                Navigator.pop(context, null);
              },
              child: Text('Clear Route'),
            ),
          ],
        ),
      ),
    );
  }
}