//Dummy create page, where user can create their own rides.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  CreatePage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      // appBar: AppBar(
      //   backgroundColor: Colors.grey[300],
      //   actions: [
      //     IconButton(
      //       onPressed: signUserOut,
      //       icon: const Icon(Icons.logout),
      //     )
      //   ],
      // ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Create a new ride session",style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                  ),),
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
                        InputDecoration(labelText: 'Pick Up Detour Margin'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      pickupDetourMargin = double.parse(value!);
                    },
                  ),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Drop Off Detour Margin'),
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
                      onPressed: () {
                        // Your button tap functionality here
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a Snackbar.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Data')),
                          );
                        }
                        print('Button tapped!');
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
