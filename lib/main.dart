import 'dart:developer';
import 'dart:io';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:rid/liste_page.dart';
import 'package:rid/settings_page.dart';
import 'dart:async';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late OpenAI openAI;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    initApiKey();
  }

  @override
  void dispose() {
    // todo : voir si on doit fermer la connexion
    // openAI.close();
    super.dispose();
  }

  Future<void> initApiKey() async {
    final _prefs = await SharedPreferences.getInstance();
    final apiKey = _prefs.getString('apiKey');
    if (apiKey == null) {
      navigatorKey.currentState?.pushReplacementNamed('/settings');
    } else {
      _isApiKeyValid = true;
      await initOpenAI(apiKey);
    }
  }

  SharedMedia? shared;
  String? _urlContent;
  String? _pageTitle;
  List<String>? _usefulParagraphs;
  String? _synthese;
  bool _isLoading = false;
  List<String>? _listImages;
  bool _isApiKeyValid = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
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
                  'You are an expert in key information extraction. Analyze the entirety of the content provided on a current affairs topic. Identify and select relevant information from the global website (all the information may not be related to the current article) to create a concise and informative summary. Present the data in a clear and digestible manner, using bullet points, tables, or a condensed format like TL/DR, according to the best way to tell the information. Ensure the summary is in the original language of the article and is free of redundancies. Content to analyze: "${joined!}"')
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
              "synthese": _synthese.toString()
            };

            final newsDictionary =
                jsonDecode(_prefs.getString("newsDictionary") ?? "{}");

            newsDictionary[shared!.content!] = page_dictionary;

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
    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/list': (context) => const ListePage(),
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24.0,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
          displayMedium: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        splashColor: Colors.yellow,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton.outlined(
              onPressed: () {
                navigatorKey.currentState?.pushNamed('/list');
              },
              icon: const Icon(Icons.account_tree_outlined)),
          actions: [
            IconButton(
                onPressed: () {
                  navigatorKey.currentState?.pushNamed('/settings');
                },
                icon: const Icon(Icons.settings)),
          ],
          title: Text(
              _pageTitle.toString() == "null" ? "Rid" : _pageTitle.toString()),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: <Widget>[
                  const SizedBox(height: 10),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _synthese != null && _synthese != ""
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    _pageTitle.toString(),
                                    style: const TextStyle(
                                      fontSize: 26.0,
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    _synthese!,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Text('No data'),

                  // ...
                ],
              ),
            ),
            const Center(
              child: Text(
                "Images : ",
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _listImages == null
                  ? SizedBox(
                      width: 150,
                      child: Image.network(
                          "https://static.vecteezy.com/system/resources/previews/010/313/693/original/emoji-feel-good-smile-happy-file-png.png"),
                    )
                  : ListView.builder(
                      itemCount: _listImages?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: 150,
                          child: Image.network(_listImages![index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSharedMediaChange(SharedMedia? media) async {
    setState(() {
      _isLoading = true;
      shared = media;
    });
    if (shared?.content?.startsWith('http') == true) {
      initPlatformState();
    }
  }

  Future<void> initOpenAI(String apiKey) async {
    openAI = OpenAI.instance.build(
        token: apiKey,
        baseOption: HttpSetup(
            receiveTimeout: const Duration(seconds: 60),
            connectTimeout: const Duration(seconds: 60)),
        enableLog: true);

    final handler = await ShareHandlerPlatform.instance;
    handler.sharedMediaStream.listen(_handleSharedMediaChange);
    shared = await handler.getInitialSharedMedia();
    if (shared?.content?.startsWith('http') == true) {
      initPlatformState();
    }
  }
}
