import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:rid/model/article_controller.dart';
import 'package:rid/page/images_page.dart';
import 'package:rid/page/settings_page.dart';
import 'package:rid/services/fetch_service.dart';
import 'package:rid/view/article_view.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'liste_page.dart';

class GenerationPage extends StatefulWidget {
  final SharedMedia sharedmedia;

  const GenerationPage({Key? key, required this.sharedmedia}) : super(key: key);

  @override
  State<GenerationPage> createState() => _GenerationPageState();
}

class _GenerationPageState extends State<GenerationPage> {
  late OpenAI openAI;
  late SharedPreferences _prefs;
  late String language = "english";

  SharedMedia? shared;
  String? domContent;
  String? title;
  String? textContent;
  String? _synthese;
  bool _isLoading = false;
  bool _isSynthetized = false;
  final List<String> _listImages = [];

  @override
  void initState() {
    super.initState();
    shared = widget.sharedmedia;
    parseArticle();
  }

  // parse Arcticle
  Future<void> parseArticle() async {
    setState(() {
      _isLoading = true;
      _synthese = "";
    });

    // Fetch the content from the URL
    final response = await http.get(
      Uri.parse("https://rid-proxy.lightin.io/?u=${shared!.content}"),
      headers: {'Content-Type': 'application/json;'},
    );
    if (response.statusCode == 200) {
      setState(() {
        final parsedResponse = jsonDecode(response.body);

        textContent = parsedResponse["textContent"];
        domContent = parsedResponse["content"];
        title = parsedResponse["title"];

        _synthese = domContent ?? "";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller =
        ArticleController(_isLoading, _synthese, title, _listImages, false);

    return ArticleView(context, controller);
  }

  Future<void> initGenerator() async {
    const storage = FlutterSecureStorage();
    final apiKey = await storage.read(key: "apiKey");
    language = await storage.read(key: "language") ?? "english";

    _prefs = await SharedPreferences.getInstance();

    if (apiKey == null) {
      if (!context.mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsPage()));
    } else {
      openAI = OpenAI.instance.build(
          token: apiKey,
          baseOption: HttpSetup(
              receiveTimeout: const Duration(seconds: 60),
              connectTimeout: const Duration(seconds: 60)),
          enableLog: true);
    }
  }

// Synthetize Article
  Future<void> synthetizeArticle() async {
    setState(() {
      _isLoading = true;
      _synthese = "";
    });

    // Fetch the content from the URL
    final response = await http.get(
      Uri.parse("https://rid-proxy.lightin.io/?u=${shared!.content}"),
      headers: {'Content-Type': 'application/json;'},
    );
    if (response.statusCode == 200) {
      setState(() {
        final parsedResponse = jsonDecode(response.body);

        textContent = parsedResponse["textContent"];
        domContent = parsedResponse["content"];
        title = parsedResponse["title"];

        // Parse the HTML content
        final dom.Document document = html.parse(domContent);

        // Get the images
        _listImages.addAll(FetchService.getImageList(document));
      });

      if (textContent != null) {
        final request = ChatCompleteText(messages: [
          Messages(
              role: Role.user,
              content:
                  'You are an expert in key information extraction. Analyze the entirety of the content provided on a current affairs topic. Identify and select relevant information from the global website (all the information may not be related to the current article) to create a concise and informative summary. Present the data in a clear and digestible manner, using tables or a condensed format like TL/DR or bullet point, according to the best way to tell important part of the information. Ensure the answer is free of redundancies. The answer must be in $language. Content to analyze: "$textContent"')
        ], maxToken: 2000, model: GptTurboChatModel());

        final res =
            await openAI.onChatCompletionSSE(request: request).listen((it) {
          debugPrint(it.choices?.last.message?.content);

          if (it.choices != null) {
            setState(() {
              log("res.choices?.first.message!.content: ${it.choices?.last.message?.content}");

              _synthese = _synthese.toString() +
                  (it.choices?.last.message?.content ?? "");

              _isLoading =
                  it.choices?.last.message?.content != null && _synthese != ""
                      ? false
                      : true;
            });

            // convert en JSON

            final page_dictionary = {
              "url": shared!.content!,
              "title": title.toString(),
              "images": _listImages,
              "synthese": _synthese.toString(),
              "date": "${DateTime.now()}"
            };

            final newsDictionary =
                jsonDecode(_prefs.getString("newsDictionary") ?? "{}");

            newsDictionary[shared!.content!] = page_dictionary;

            log("newsDictionary: ${newsDictionary.toString()}");

            _prefs.setString("newsDictionary", jsonEncode(newsDictionary));
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    }
  }
}
