//show upcoming travel plans in list view and allows for the ability to click particular travel plans to see more information
import 'package:commute_connect/pages/past_travel_page.dart';
import 'package:commute_connect/pages/travel_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TravelPlansPage extends StatefulWidget {
  const TravelPlansPage({super.key});

  @override
  State<TravelPlansPage> createState() => _TravelPlansPageState();
}

class _TravelPlansPageState extends State<TravelPlansPage> {
  final String user = FirebaseAuth.instance.currentUser!.uid.toString();
  late DatabaseReference ref;
  bool _isLoading = true;
  late DateTime now;
  Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref('user/$user/ride');
    fetchData();
    now = DateTime.now().toLocal();
  }

  //partitioning data to only show past travel plans and adding delay for circular progress indicator
  Future<void> fetchData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      await ref
          .orderByChild('date_new')
          .startAt(DateTime.now().millisecondsSinceEpoch)
          .once();
    } catch (error) {
      print('Error fetching data: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //scroll refresh that refreshes the current date/time(the only thing that can really change on the page)
  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    now = DateTime.now().toLocal();
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    int dateMilliseconds = now.millisecondsSinceEpoch;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Column(
            children: [
              StreamBuilder(
                  stream: ref
                      .orderByChild('date_new')
                      .startAt(dateMilliseconds)
                      .onValue,
                  builder: (context, snapshot) {
                    //displays rides in list view and shows circular porgross indicator when loading page
                    if (snapshot.hasData &&
                        snapshot.data?.snapshot.value != null) {
                      return _isLoading
                          ? const Padding(
                              padding: EdgeInsets.only(top: 300, bottom: 246),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.black),
                              ),
                            )
                          : Expanded(
                              child: FirebaseAnimatedList(
                                  query: ref
                                      .orderByChild('date_new')
                                      .startAt(dateMilliseconds),
                                  itemBuilder:
                                      (context, snapshot, animation, index) {
                                    DateTime date =
                                        DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(snapshot
                                                    .child('date_new')
                                                    .value
                                                    .toString()),
                                                isUtc: true)
                                            .toLocal();
                                    return
                                        //darkens box around ride information to show it is clickable
                                        InkWell(
                                            //passing values to travel detials page
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return TravelDetailsPage(
                                                  from: snapshot
                                                      .child('from')
                                                      .value
                                                      .toString(),
                                                  to: snapshot
                                                      .child('to')
                                                      .value
                                                      .toString(),
                                                  dateTime: date.toString(),
                                                  keyValue: snapshot
                                                      .child('key')
                                                      .value
                                                      .toString(),
                                                  user: user,
                                                );
                                              }));
                                            },
                                            onHover: (hovering) {
                                              setState(() {
                                                if (hovering) {
                                                  backgroundColor =
                                                      Colors.grey.shade400;
                                                } else {
                                                  backgroundColor =
                                                      Colors.white;
                                                }
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Card(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0)),
                                                      elevation: 2,
                                                      color: backgroundColor,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                //from(location) details ui
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const Text(
                                                                        'From',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                      Text(
                                                                        snapshot
                                                                            .child('from')
                                                                            .value
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Icon(Icons
                                                                    .arrow_forward),
                                                                //to(location) details ui
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      const Text(
                                                                        'To',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                      Text(
                                                                        snapshot
                                                                            .child('to')
                                                                            .value
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            const Divider(),
                                                            const SizedBox(
                                                                height: 16),
                                                            //date and time info ui
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                const Text(
                                                                  'Date & Time',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  date.toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ));
                                  }));
                    } else {
                      //shows circular progress indicator and a messgage saying there are no past travel plans available when there is no data from the database
                      return _isLoading
                          ? const Padding(
                              padding: EdgeInsets.only(top: 300, bottom: 246),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.black),
                              ),
                            )
                          : const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 290, bottom: 263),
                                child: Text(
                                  'No upcoming travel plans available',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                    }
                  }),

              //view past acitivity button ui
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PastTravelPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 127, vertical: 11),
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'View Past Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
