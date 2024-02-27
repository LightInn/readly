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
      "images": jsonEncode(article.listImagesUrls),
      "content": article.content.toString(),
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
      content: article["content"],
      listImagesUrls: article["images"],
      date: article["date"],
    );
  }

  Future<List<Article>> getAllHistory() async {
    // initialiser les préférences
    await iniPrefs();

    // get the newsDictionary from the shared preferences
    final newsDictionary =
        jsonDecode(_prefs.getString("newsDictionary") ?? "{}");

    print(newsDictionary);

    // Convertir toutes les valeurs (chaque article) en objets Article
    var articles = newsDictionary.values.map<Article>((articleMap) {
      // Assure-toi que articleMap est bien un Map avant de l'utiliser
      Map<String, dynamic> article = Map<String, dynamic>.from(articleMap);

      return Article(
          url: article['url'],
          title: article['title'],
          content: article['content'],
          listImagesUrls: List<String>.from(jsonDecode(article['images'])),
          // Convertir en List<String> si nécessaire
          date: DateTime.parse(article['date']));
    }).toList(); // Convertir le résultat itérable en List avec toList()

    return articles;
  }

  Future<void> deleteHistory(String url) async {
    // initialiser les préférences
    await iniPrefs();

    // get the newsDictionary from the shared preferences
    final newsDictionary =
        jsonDecode(_prefs.getString("newsDictionary") ?? "{}");

    // remove the article from the newsDictionary
    newsDictionary.remove(url);

    // save the newsDictionary to the shared preferences
    _prefs.setString("newsDictionary", jsonEncode(newsDictionary));
  }
}
