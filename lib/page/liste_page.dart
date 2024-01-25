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

  TextEditingController _apiKeyController = TextEditingController();

  bool _isLoading = false;
  late Map<String, dynamic> newsDictionary;

  @override
  void initState() {
    super.initState();
    _checkNewsDictionary();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _checkNewsDictionary() async {
    _isLoading = true;
    _prefs = await SharedPreferences.getInstance();

    final newsDictionary = _prefs.getString('newsDictionary') ?? '{}';

    this.newsDictionary = jsonDecode(newsDictionary);
    log(this.newsDictionary.keys.toString());
    log(this.newsDictionary.length.toString());
    setState(() {
      this._isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),

              // liste des news dans le dictionnaire

              child: ListView.builder(
                  itemCount: this.newsDictionary.length,
                  itemBuilder: (context, index) {
                    String key = this.newsDictionary.keys.elementAt(index);
                    return Card(
                      child: ListTile(
                        onTap: () {
                          // open in main page the url
                          log("tapped");

                          // final url = this.newsDictionary[key]['url'];
                          Synthese gen = Synthese(
                            url: this.newsDictionary[key]['url'],
                            title: this.newsDictionary[key]['title'],
                            synthese: this.newsDictionary[key]['synthese'],
                            listImages: this.newsDictionary[key]['listImages'],
                          );

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewPage(
                                        synthese: gen,
                                      )));
                          log("ca a push ?");
                        },
                        title: Text(this.newsDictionary[key]['title'] ?? "??"),
                        subtitle:
                            Text(this.newsDictionary[key]['date'] ?? "??"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            setState(() {
                              this.newsDictionary.remove(key);
                              _prefs.setString('newsDictionary',
                                  jsonEncode(this.newsDictionary));
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
