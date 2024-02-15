import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:rid/model/article_controller.dart';
import 'package:rid/services/fetch_service.dart';
import 'package:rid/view/article_view.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';

class SimplifyPage extends StatefulWidget {
  final SharedMedia sharedmedia;

  const SimplifyPage({Key? key, required this.sharedmedia}) : super(key: key);

  @override
  State<SimplifyPage> createState() => _SimplifyPageState();
}

class _SimplifyPageState extends State<SimplifyPage> {
  late bool _isOpenAI;
  SharedMedia? shared;
  String? domContent;
  String? title;
  String? textContent;
  String? _synthese;
  bool _isLoading = false;
  final List<String> _listImages = [];

  @override
  void initState() {
    super.initState();
    shared = widget.sharedmedia;
    parseArticle();
  }

  // parse Arcticle
  Future<void> parseArticle() async {
    const storage = FlutterSecureStorage();
    _isOpenAI = await storage.read(key: "apiKey") != null ? true : false;

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
      });
      // Fetch the images using service
      final dom.Document document = html.parse(domContent);
      _listImages.addAll(FetchService.getImageList(document));

      setState(() {
        _isLoading = false;
        log("CHANGE STATE");
        _synthese = textContent ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller =
        ArticleController(_isLoading, _synthese, title, _listImages, _isOpenAI, shared!.content);

    return ArticleView(context, controller);
  }
}
