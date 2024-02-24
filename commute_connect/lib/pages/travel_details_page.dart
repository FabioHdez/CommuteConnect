import 'package:flutter/material.dart';

class TravelDetailsPage extends StatefulWidget {
  final String location;
  final String dateTime;
  const TravelDetailsPage(
      {super.key, required this.location, required this.dateTime});

  @override
  State<TravelDetailsPage> createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Travel Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 300, left: 95),
            child: Text(
              "From: Downtown Miami\nTo: ${widget.location}\n${widget.dateTime}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
