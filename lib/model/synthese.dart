import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Synthese {
  late String url;
  String? title;
  List<String>? listImages;
  String? synthese;
  late DateTime date;

  Synthese({
    required this.url,
    this.title,
    this.listImages,
    this.synthese,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}
