import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:readly/model/article.dart';
import 'package:readly/page/view_page.dart';
import 'package:readly/services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late SharedPreferences _prefs;

  bool _isLoading = false;

  late List<Article> _articlesList;

  @override
  void initState() {
    super.initState();
    _checkNewsDictionary();
  }

  Future<void> _checkNewsDictionary() async {
    _isLoading = true;

    var histories = await HistoryService().getAllHistory();

    setState(() {
      _articlesList = histories;
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
                  itemCount: _articlesList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewPage(
                                        synthese: _articlesList[index],
                                      )));
                        },
                        title: Text(_articlesList[index].title ?? "??"),
                        subtitle: Text(_articlesList[index].date.toString()),
                        splashColor: Colors.white38,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await HistoryService()
                                .deleteHistory(_articlesList[index].url);
                            setState(() {
                              _checkNewsDictionary();
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
