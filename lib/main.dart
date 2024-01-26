import 'dart:developer';
import 'dart:io';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:rid/page/generation_page.dart';
import 'package:rid/page/liste_page.dart';
import 'package:rid/page/settings_page.dart';
import 'dart:async';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: const GenerationPage(),
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
  ));
}

// TODO : faire un how to par defaut, mettre le hookListener et redirect vers la page de generation si besoin
