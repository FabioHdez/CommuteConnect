//Dummy travel plans page, where user can see their future travel plans.

import 'package:commute_connect/pages/past_travel_page.dart';
import 'package:commute_connect/pages/travel_details_page.dart';
import 'package:flutter/material.dart';

class TravelPlansPage extends StatefulWidget {
  const TravelPlansPage({super.key});

  @override
  State<TravelPlansPage> createState() => _TravelPlansPageState();
}

class _TravelPlansPageState extends State<TravelPlansPage> {
  final String location = 'Miami Beach';

  final String dateTime = 'June 19, 2023 • 8:30 AM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Travel Plans",
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // const SizedBox(height: 20),
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 22.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: [
            //       Text('Upcoming',
            //           style: TextStyle(
            //               color: Colors.black,
            //               fontSize: 20,
            //               fontWeight: FontWeight.bold)),
            //     ],
            //   ),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TravelDetailsPage(
                            location: location, dateTime: dateTime);
                      }));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(15)),
                      margin:
                          const EdgeInsets.only(left: 20, top: 20, right: 20),
                      child: ListTile(
                        title: Text(
                          location,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          dateTime,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        trailing: const IconButton(
                          icon: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                          ),
                          onPressed: null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PastTravelPage();
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 120, right: 120, top: 25, bottom: 25),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text(
                          "View Past Acitivty",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
