import 'package:flutter/material.dart';
import 'package:readly/model/article_controller.dart';
import 'package:readly/view/article_view.dart';

import '../model/article.dart';

class ViewPage extends StatefulWidget {
  final Article synthese;

  const ViewPage({Key? key, required this.synthese}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  Article get synthese => widget.synthese;

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
    var controller = ArticleController(
        false,
        widget.synthese.content,
        widget.synthese.title,
        widget.synthese.listImagesUrls,
        false,
        widget.synthese.url);

    return ArticleView(context, controller);
  }
}
