import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:rid/model/article_controller.dart';
import 'package:rid/model/synthese.dart';
import 'package:rid/page/generation_page.dart';
import 'package:rid/page/settings_page.dart';
import 'package:rid/view/article_view.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HookService {
  static getInitialSharedMedia(BuildContext context) async {
    final handler = ShareHandlerPlatform.instance;

    handler.sharedMediaStream
        .listen((media) => _handleHookChange(media, context));

    SharedMedia? shared = await handler.getInitialSharedMedia();
    log("Awaited shared : ");
    if (shared != null && shared.content?.startsWith('http') == true) {
      if (!context.mounted) return;
      redirect(context, shared);
    }
  }

  // Only if a new url is shared
  static void _handleHookChange(SharedMedia media, BuildContext context) async {
    log("Hook change !!! ");

    if (media.content?.startsWith('http') == true) {
      if (!context.mounted) return;
      redirect(context, media);
    }
  }

  static void redirect(BuildContext context, SharedMedia media)  {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GenerationPage(
                  sharedmedia: media,
                )));

    // TODO : check if the url is an article
    // TODO : check if the url is already in the list
    // TODO : add the url to the list
    // TODO : redirect to the generation page
  }
}
