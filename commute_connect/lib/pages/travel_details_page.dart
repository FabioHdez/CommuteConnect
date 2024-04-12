//travel details page, shows more details about a specific ride and allows the user to cancel ride if desired
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TravelDetailsPage extends StatefulWidget {
  final String to;
  final String from;
  final String dateTime;
  final String keyValue;
  final String user;

  const TravelDetailsPage({
    Key? key,
    required this.to,
    required this.from,
    required this.dateTime,
    required this.keyValue,
    required this.user,
  }) : super(key: key);

  @override
  State<TravelDetailsPage> createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage> {
  late DatabaseReference _driverRef;
  late DatabaseReference _carRef;
  late DatabaseReference _passengersRef;
  String _driverName = '';
  String _driverName2 = '';
  String _carDetails = '';
  List<String> _passengers = [];
  List<String> _passengers2 = [];
  List<String> _passengers3 = [];
  late DateTime _dateTimeUTC;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _driverRef =
        FirebaseDatabase.instance.ref('trips/${widget.keyValue}/driver');
    _carRef =
        FirebaseDatabase.instance.ref('trips/${widget.keyValue}/car_details');
    _passengersRef = FirebaseDatabase.instance.ref('trips/${widget.keyValue}');
    _fetchDriverName();
    _fetchCarDetails();
    _fetchPassengers();
    _dateTimeUTC = DateTime.parse(widget.dateTime).toUtc();
  }

  //getting the name of the driver to print out later
  void _fetchDriverName() {
    _driverRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        setState(() {
          _driverName = event.snapshot.value.toString();
          DatabaseReference driverRef2 = FirebaseDatabase.instance
              .ref('user/${_driverName.toString()}/info/name');
          driverRef2.once().then((DatabaseEvent event) {
            _driverName2 = event.snapshot.value.toString();
          });
        });
      }
    }).catchError((error) {
      print('Error fetching driver name: $error');
    });
  }

  //getting the car details to print out later
  void _fetchCarDetails() {
    _carRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        setState(() {
          _carDetails = event.snapshot.value.toString();
        });
      }
    }).catchError((error) {
      print('Error fetching car details: $error');
    });
  }

  //getting all the passengers in the ride to print out later
  void _fetchPassengers() {
    _passengers.clear();
    _passengersRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? passengersMap =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (passengersMap != null) {
          passengersMap.forEach((key, value) {
            if (key.toString().startsWith('passenger')) {
              _passengers.add(value.toString());
            }
          });
          setState(() {});
        }
      }
      if (_passengers.isNotEmpty) {
        for (int x = 0; x < _passengers.length; x++) {
          DatabaseReference passengerRef2 = FirebaseDatabase.instance
              .ref('user/${_passengers[x].toString()}/info/name');
          passengerRef2.once().then((DatabaseEvent event) {
            _passengers3.add(event.snapshot.value.toString());
          });
        }
      }
    }).catchError((error) {
      print('Error fetching passengers: $error');
    });
  }

  //logic for canceling ride for either a passenger or driver in a ride
  void _cancelRide() {
    _passengers2.clear();
    //logic for canceling ride for passenger
    //first deletes passenger's name from trips tree in database
    if (_driverName != widget.user) {
      _passengersRef.once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? passengersMap2 =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (passengersMap2 != null) {
            passengersMap2.forEach((key, value) {
              if (key.toString().startsWith('passenger') &&
                  value.toString().contains(widget.user)) {
                _passengers2.add(key.toString());
                _passengersRef
                    .child(_passengers2[0].toString())
                    .remove()
                    .then((_) {
                  print('Passenger data deleted successfully');
                }).catchError((error) {
                  print('Error deleting passenger data: $error');
                });
              }
            });

            //secondly, deletes ride information for particular user in the user tree
            DatabaseReference rideRef =
                FirebaseDatabase.instance.ref('user/${widget.user}/ride');
            rideRef.once().then((DatabaseEvent event) {
              Map<dynamic, dynamic>? ridesMap =
                  event.snapshot.value as Map<dynamic, dynamic>?;
              if (ridesMap != null) {
                ridesMap.forEach((rideKey, tripInfo) {
                  if (tripInfo.toString().contains(widget.keyValue)) {
                    rideRef.child(rideKey.toString()).remove().then((_) {
                      print('Ride data deleted successfully');
                    }).catchError((error) {
                      print('Error deleting ride data: $error');
                    });
                  }
                });
              }
            });
          }
        }
      });
      //logic for canceling ride for driver
      //first stores all passenger's names in list for later use
    } else if (_driverName == widget.user) {
      _passengersRef.once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? passengersMap2 =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (passengersMap2 != null) {
            passengersMap2.forEach((key, value) {
              if (key.toString().startsWith('passenger')) {
                _passengers2.add(value.toString());
                //secondly, using list of names, deletes ride information for all user in the user tree
                for (int j = 0; j < _passengers2.length; j++) {
                  DatabaseReference rideRef = FirebaseDatabase.instance
                      .ref('user/${_passengers2[j].toString()}/ride');
                  rideRef.once().then((DatabaseEvent event) {
                    Map<dynamic, dynamic>? ridesMap =
                        event.snapshot.value as Map<dynamic, dynamic>?;
                    if (ridesMap != null) {
                      ridesMap.forEach((rideKey, tripInfo) {
                        if (tripInfo.toString().contains(widget.keyValue)) {
                          rideRef.child(rideKey.toString()).remove().then((_) {
                            print('All user ride data deleted successfully');
                          }).catchError((error) {
                            print('Error deleting ride data: $error');
                          });
                        }
                      });
                    }
                  });
                }
              }
            });
          }
        }
        //thridly, deletes trip information from trip tree
        DatabaseReference tripRef =
            FirebaseDatabase.instance.ref('trips/${widget.keyValue}');
        tripRef.remove().then((_) {
          print('Trip data deleted successfully');
        }).catchError((error) {
          print('Error deleting ride data: $error');
        });

        //lastly, deletes ride information for particular user (the driver) in the user tree
        DatabaseReference rideRef =
            FirebaseDatabase.instance.ref('user/${widget.user}/ride');
        rideRef.once().then((DatabaseEvent event) {
          Map<dynamic, dynamic>? ridesMap =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (ridesMap != null) {
            ridesMap.forEach((rideKey, tripInfo) {
              if (tripInfo.toString().contains(widget.keyValue)) {
                rideRef.child(rideKey.toString()).remove().then((_) {
                  print('Current user ride data deleted successfully');
                }).catchError((error) {
                  print('Error deleting ride data: $error');
                });
              }
            });
          }
        });
      });
    } else {
      print('Error');
    }
  }

  //shows dialog box to ask user to confirm wether they want to cancel ride or not
  //if yes, uses _cancelRide() method and takes user back to travelplans page, else, nothing
  void _confirmCancelRide() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Ride Confirmation'),
          content: const Text('Are you sure you want to cancel this ride?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _cancelRide();
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed != null && confirmed) {
        setState(() {
          _isLoading = true;
        });
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      }
    });
  }

  //scroll refresh that refreshes the passengers list(the only thing that can really change on the page)
  Future<void> _handleRefresh() async {
    _fetchPassengers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Ride Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 800)),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            } else {
              bool showCancelButton = DateTime.now().isBefore(_dateTimeUTC);
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                color: Colors.black,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Ride',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //from(location) info ui
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'From',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            widget.from,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward),

                                    //to(location) info ui
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'To',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            widget.to,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),

                                //Date and time info ui
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Date & Time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.dateTime,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),

                                //car details ui
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Car Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _carDetails,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),

                                //driver info ui
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Driver',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _driverName2,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),

                                //passenger info ui
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Passengers',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _passengers.isEmpty
                                        ? const Text(
                                            'No Passengers Available',
                                            style: TextStyle(fontSize: 14),
                                          )
                                        : Expanded(
                                            child: SizedBox(
                                              height: 135,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: _passengers.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 15.0),
                                                    child: Text(
                                                        _passengers3[index]),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        //cancel button ui
                        const SizedBox(height: 24),
                        if (showCancelButton)
                          ElevatedButton(
                            onPressed: _confirmCancelRide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Cancel Ride',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }
}
