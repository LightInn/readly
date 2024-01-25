import 'package:flutter/material.dart';
import 'package:rid/model/article_controller.dart';
import 'package:rid/view/article_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/synthese.dart';

class ViewPage extends StatefulWidget {
  final Synthese synthese;

  const ViewPage({Key? key, required this.synthese}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  Synthese get synthese => widget.synthese;

  late SharedPreferences _prefs;

  TextEditingController _apiKeyController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _checkApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey(String apiKey) async {
    setState(() {
      _isLoading = true;
    });

    await _prefs.setString('apiKey', apiKey);
    final prefs = await _prefs;
    await prefs.setBool('hasApiKey', true);

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushReplacementNamed("/");
  }

  @override
  Widget build(BuildContext context) {
    var controller = ArticleController(false, widget.synthese.synthese,
        widget.synthese.title, widget.synthese.listImages);

    return ArticleView(context, controller);
  }
}
