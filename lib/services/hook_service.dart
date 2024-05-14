import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:readly/page/simplify_page.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';

class HookService {
  static getInitialSharedMedia(BuildContext context) async {
    final handler = ShareHandlerPlatform.instance;

    handler.sharedMediaStream
        .listen((media) => _handleHookChange(media, context));

    SharedMedia? shared = await handler.getInitialSharedMedia();
    log("Awaited shared : ");

    if (shared != null) {
      RegExp urlPattern = RegExp(r'(http[s]?://\S+)');
      String? extractedUrl =
          urlPattern.firstMatch(shared.content ?? '')?.group(0);

      var extractedMedia = SharedMedia(content: extractedUrl);

      if (!context.mounted) return;
      redirect(context, extractedMedia, overwrite: true);
    }
  }

  // Only if a new url is shared
  static void _handleHookChange(SharedMedia media, BuildContext context) async {
    log("Hook change !!! ");
    log(media.content.toString());

    // Utiliser une expression régulière pour extraire l'URL
    RegExp urlPattern = RegExp(r'(http[s]?://\S+)');
    String? extractedUrl = urlPattern.firstMatch(media.content ?? '')?.group(0);
    log(extractedUrl.toString());

    var extractedMedia = SharedMedia(content: extractedUrl);

    if (extractedUrl != null && extractedUrl.startsWith('http')) {
      if (!context.mounted) return;
      redirect(context, extractedMedia);
    }
  }

  static void redirect(BuildContext context, SharedMedia media,
      {bool overwrite = false}) {
    if (overwrite) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SimplifyPage(
                    sharedmedia: media,
                  )));
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SimplifyPage(
                  sharedmedia: media,
                )));

    // TODO : check if the url is an article
    // TODO : check if the url is already in the list
    // TODO : add the url to the list
    // TODO : redirect to the generation page
  }
}
