import 'package:flutter/material.dart';
import 'package:rid/page/welcome_page.dart';

void main() {
  runApp(MaterialApp(
    // home: const GenerationPage(), // Back to the roots
    home: const WelcomePage(), // How to page
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
