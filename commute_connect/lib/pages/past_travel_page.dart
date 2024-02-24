import 'package:commute_connect/pages/travel_details_page.dart';
import 'package:flutter/material.dart';

class PastTravelPage extends StatefulWidget {
  const PastTravelPage({super.key});

  @override
  State<PastTravelPage> createState() => _PastTravelPageState();
}

class _PastTravelPageState extends State<PastTravelPage> {
  final String location = 'South Beach';

  final String dateTime = 'July 12, 2024 • 9:00 PM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Past Travel Plans",
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 10,
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
            const SizedBox(height: 20),
          ],
        ));
  }
}
