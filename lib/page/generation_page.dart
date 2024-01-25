import 'dart:developer';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:rid/model/article_controller.dart';
import 'package:rid/model/synthese.dart';
import 'package:rid/page/liste_page.dart';
import 'package:rid/page/settings_page.dart';
import 'package:rid/view/article_view.dart';
import 'dart:async';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GenerationPage extends StatefulWidget {
  final Synthese? synthese;

  const GenerationPage({Key? key, this.synthese}) : super(key: key);

  @override
  State<GenerationPage> createState() => _GenerationPageState();
}

class _GenerationPageState extends State<GenerationPage> {
  late OpenAI openAI;
  late SharedPreferences _prefs;

  SharedMedia? shared;
  String? _urlContent;
  String? _pageTitle;
  List<String>? _usefulParagraphs;
  String? _synthese;
  bool _isLoading = false;
  List<String>? _listImages;

  @override
  void initState() {
    super.initState();
    initGenerator();
  }

  Future<void> initGenerator() async {
    final storage = FlutterSecureStorage();
    final apiKey = await storage.read(key: "apiKey");

    _prefs = await SharedPreferences.getInstance();
    // final apiKey = _prefs.getString('apiKey');

    if (apiKey == null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsPage()));
    } else {
      openAI = OpenAI.instance.build(
          token: apiKey,
          baseOption: HttpSetup(
              receiveTimeout: const Duration(seconds: 60),
              connectTimeout: const Duration(seconds: 60)),
          enableLog: true);

      await initHookListener(apiKey);
    }
  }

  Future<void> initHookListener(String apiKey) async {
    final handler = await ShareHandlerPlatform.instance;
    handler.sharedMediaStream.listen(_handleHookChange);
    shared = await handler.getInitialSharedMedia();
    if (shared?.content?.startsWith('http') == true) {
      synthetizeArticle();
    }
  }

  // Only if a new url is shared
  void _handleHookChange(SharedMedia? media) async {
    setState(() {
      _isLoading = true;
      shared = media;
    });
    if (shared?.content?.startsWith('http') == true) {
      synthetizeArticle();
    }
  }

  Future<void> synthetizeArticle() async {
    setState(() {
      _isLoading = true;
      _synthese = "";
    });

    // Fetch the content from the URL
    final response = await http.get(
      Uri.parse(shared!.content!),
      headers: {'Content-Type': 'text/html;'},
    );
    if (response.statusCode == 200) {
      setState(() {
        _urlContent = response.body;
        final document = html.parse(_urlContent!);
        final titleElement = document.querySelector('title');
        if (titleElement != null) {
          _pageTitle = titleElement.text;
        }

        // Récupérer tous les éléments <img>
        final imgElements = document.querySelectorAll('img');
        _listImages = [];
        // Extraire l'URL de chaque image et les ajouter à la liste
        for (final img in imgElements) {
          log("img: ${img.attributes['src']}");
          final src = img.attributes['src'];

          if (src != null) {
            Uri? uri = Uri.tryParse(src);
            if (uri != null &&
                uri.isAbsolute &&
                (uri.scheme == 'http' || uri.scheme == 'https')) {
              _listImages?.add(src);
            }
          }
        }

        final contentType = response.headers['content-type'];
        if (contentType != null) {
          final charsetMatch =
              RegExp('charset=([\\w-]+)').firstMatch(contentType);
          if (charsetMatch != null) {
            final charset = charsetMatch.group(1);
            final encoder = Encoding.getByName(charset);
            _usefulParagraphs = document
                .querySelectorAll('p')
                .map((p) => p.text.trim())
                .toList();
          }
        }
      });

      if (_usefulParagraphs != null) {
        var joined = _usefulParagraphs?.isNotEmpty == true
            ? _usefulParagraphs!.join(" \n ")
            : '';

        final request = ChatCompleteText(messages: [
          Messages(
              role: Role.user,
              content:
                  'You are an expert in key information extraction. Analyze the entirety of the content provided on a current affairs topic. Identify and select relevant information from the global website (all the information may not be related to the current article) to create a concise and informative summary. Present the data in a clear and digestible manner, using tables or a condensed format like TL/DR or bullet point, according to the best way to tell important part of the information. Ensure the answer is in the same language as the content I give you and is free of redundancies. Content to analyze: "${joined!}"')
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
              "title": _pageTitle.toString(),
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

    if (!mounted) return;
    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    var controller =
        ArticleController(_isLoading, _synthese, _pageTitle, _listImages);

    return ArticleView(context, controller);
  }
}
