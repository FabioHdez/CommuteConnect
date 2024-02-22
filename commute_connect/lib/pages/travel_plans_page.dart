//Dummy travel plans page, where user can see their future travel plans.

import 'package:commute_connect/components/my_button.dart';
import 'package:flutter/material.dart';

class TravelPlansPage extends StatelessWidget {
  const TravelPlansPage({super.key});

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
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Upcoming',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.only(left: 20, top: 20, right: 20),
                    child: const ListTile(
                      title: Text(
                        "Miami Beach",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "June 19, 2023 • 8:30 AM",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                        ),
                        onPressed: null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: MyButton(
                text: "View Past Activity",
                onTap: null,
              ),
            ),
          ],
        ));
  }
}
