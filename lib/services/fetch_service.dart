import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import 'package:rid/page/generation_page.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';

class FetchService {
  static getImageList(Document document) {
    // Récupérer tous les éléments <img>
    final imgElements = document.querySelectorAll('img');

    var listImages = <String>[];

    // Extraire l'URL de chaque image et les ajouter à la liste
    for (final img in imgElements) {
      log("img: ${img.attributes['src']}");
      final src = img.attributes['src'];

      if (src != null) {
        Uri? uri = Uri.tryParse(src);
        if (uri != null &&
            uri.isAbsolute &&
            (uri.scheme == 'http' || uri.scheme == 'https')) {
          listImages.add(src);
        }
      }
    }

    return listImages;
  }
}
