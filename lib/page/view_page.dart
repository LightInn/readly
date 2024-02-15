import 'package:flutter/material.dart';
import 'package:rid/model/article_controller.dart';
import 'package:rid/view/article_view.dart';

import '../model/synthese.dart';

class ViewPage extends StatefulWidget {
  final Synthese synthese;

  const ViewPage({Key? key, required this.synthese}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  Synthese get synthese => widget.synthese;

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

  @override
  Widget build(BuildContext context) {
    var controller = ArticleController(false, widget.synthese.synthese,
        widget.synthese.title, widget.synthese.listImages, false);

    return ArticleView(context, controller);
  }
}
