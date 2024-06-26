import 'package:flutter/material.dart';

class MySearchBar extends StatefulWidget {
  final TextEditingController controller;
  const MySearchBar({super.key, required this.controller});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
         padding: const EdgeInsets.all(54),
          child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: widget.controller,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              // onTap: () {
              //   controller.openView();
              // },
              // onChanged: (_) {
              //   controller.openView();
              // },
              leading: const Icon(Icons.search),
            );
          }, isFullScreen: false,
          suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = 'Recent place: $index';
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                  });
                },
              );
            });
          }),
    );
  }
}
