import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rid/main.dart';
import 'package:rid/model/synthese.dart';
import 'package:rid/page/view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ListePage extends StatefulWidget {
  const ListePage({Key? key}) : super(key: key);

  @override
  _ListePageState createState() => _ListePageState();
}

class _ListePageState extends State<ListePage> {
  late SharedPreferences _prefs;

  bool _isLoading = false;

  late Map<String, dynamic> newsDictionary;

  @override
  void initState() {
    super.initState();
    _checkNewsDictionary();
  }

  Future<void> _checkNewsDictionary() async {
    _isLoading = true;
    _prefs = await SharedPreferences.getInstance();

    final newsDictionary = _prefs.getString('newsDictionary') ?? '{}';

    this.newsDictionary = jsonDecode(newsDictionary);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),

              // liste des news dans le dictionnaire

              child: ListView.builder(
                  itemCount: newsDictionary.length,
                  itemBuilder: (context, index) {
                    String key = newsDictionary.keys.elementAt(index);
                    return Card(
                      child: ListTile(
                        onTap: () {
                          // final url = this.newsDictionary[key]['url'];
                          Synthese gen = Synthese(
                            url: newsDictionary[key]['url'],
                            title: newsDictionary[key]['title'],
                            synthese: newsDictionary[key]['synthese'],
                            listImages: [],
                            // TODO get list images
                            // listImages: newsDictionary[key]['images'],
                          );
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewPage(
                                        synthese: gen,
                                      )));
                        },
                        title: Text(newsDictionary[key]['title'] ?? "??"),
                        subtitle: Text(newsDictionary[key]['date'] ?? "??"),
                        splashColor: Colors.white38,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            setState(() {
                              newsDictionary.remove(key);
                              _prefs.setString(
                                  'newsDictionary', jsonEncode(newsDictionary));
                            });
                          },
                        ),
                      ),
                    );
                  }),
            ),
    );
  }
}
