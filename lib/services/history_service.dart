import 'dart:convert';
import 'dart:developer';

import 'package:html/dom.dart';
import 'package:readly/model/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  late SharedPreferences _prefs;

  iniPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  saveHistory(Article article) async {
    // initialiser les préférences
    await iniPrefs();

    // convert Article to JSON dictionary
    final page_dictionary = {
      "url": article.url.toString(),
      "title": article.title.toString(),
      // "images": article.imagesList.toString(),
      "content": article.synthese.toString(),
      "date": "${DateTime.now()}"
    };

    // get the newsDictionary from the shared preferences
    final newsDictionary =
        jsonDecode(_prefs.getString("newsDictionary") ?? "{}");

    // add the new article to the newsDictionary
    newsDictionary[article.url.toString()] = page_dictionary;

    // save the newsDictionary to the shared preferences
    _prefs.setString("newsDictionary", jsonEncode(newsDictionary));
  }

  Future<Article> getHistory(String url) async {
    // initialiser les préférences
    await iniPrefs();

    // get the newsDictionary from the shared preferences
    final newsDictionary =
        jsonDecode(_prefs.getString("newsDictionary") ?? "{}");

    // get the article from the newsDictionary
    final article = newsDictionary[url];

    // convert the article to an Article object
    return Article(
      url: article["url"],
      title: article["title"],
      synthese: article["content"],
      // imagesList: article["images"],
      date: article["date"],
    );
  }
}
