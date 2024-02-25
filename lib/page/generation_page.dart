import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readly/model/article_controller.dart';
import 'package:readly/model/article.dart';
import 'package:readly/page/settings_page.dart';
import 'package:readly/services/history_service.dart';
import 'package:readly/view/article_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerationPage extends StatefulWidget {
  final ArticleController articleController;

  const GenerationPage({super.key, required this.articleController});

  @override
  State<GenerationPage> createState() => _GenerationPageState();
}

class _GenerationPageState extends State<GenerationPage> {
  late OpenAI openAI;
  late SharedPreferences _prefs;
  late String language = "english";

  late ArticleController articleController;

  String? _content;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    articleController = widget.articleController;
    initGenerator();
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

      synthetizeArticle();
    }
  }

// Synthetize Article
  Future<void> synthetizeArticle() async {
    setState(() {
      _isLoading = true;
      _content = "";
    });

    if (articleController.content != null) {
      final request = ChatCompleteText(messages: [
        Map.of({
          "role": "user",
          "content":
              'You are an expert in key information extraction. Analyze the entirety of the content provided on a current affairs topic. Identify and select relevant information from the global website (all the information may not be related to the current article) to create a concise and informative summary. Present the data in a clear and digestible manner, using tables or a condensed format like TL/DR or bullet point, according to the best way to tell important part of the information. Ensure the answer is free of redundancies. The answer must be in $language. Content to analyze: "${articleController.content}"'
        })
      ], maxToken: 2000, model: GptTurboChatModel());

      final res =
          await openAI.onChatCompletionSSE(request: request).listen((it) {
        debugPrint(it.choices?.last.message?.content);

        if (it.choices != null) {
          setState(() {
            log("res.choices?.first.message!.content: ${it.choices?.last.message?.content}");

            _content =
                _content.toString() + (it.choices?.last.message?.content ?? "");

            _isLoading =
                it.choices?.last.message?.content != null && _content != ""
                    ? false
                    : true;
          });

          var articleToSave = Article(
            url: articleController.url.toString(),
            title: articleController.title.toString(),
            content: _content.toString(),
            listImagesUrls: articleController.listImagesUrls,
          );

          // save the article to the history
          HistoryService().saveHistory(articleToSave);
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });

      if (res == null) {
        if (!context.mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = ArticleController(
        _isLoading,
        _content,
        articleController.title.toString(),
        articleController.listImagesUrls,
        false,
        articleController.url.toString());

    return ArticleView(context, controller);
  }
}
