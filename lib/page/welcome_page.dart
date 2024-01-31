import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rid/page/generation_page.dart';
import 'package:rid/page/settings_page.dart';
import 'package:rid/services/hook_service.dart';
import 'package:share_handler/share_handler.dart';

// The WelcomePage is the first page of the app. it have the "how to" information and have a button to go to the settings page
class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    pageRedirect();
  }

  void pageRedirect() async {
    await HookService.getInitialSharedMedia(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Rid"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                },
                icon: const Icon(Icons.settings)),
          ],
        ),
        body: Column(children: [
          Expanded(
              child: ListView(children: <Widget>[
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  const Text(
                    "Bienvenue sur Rid !",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Rid est une application qui permet de générer des résumés de texte à partir d'un article de presse.",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Pour cela, il suffit de partager l'url d'un article vers l'application",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),

                  // TODO : Ajouter une image pour montrer comment partager un article
                  // l'image doit etre rounded

                  const SizedBox(height: 30),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(18.0),
                      child: Image(
                        image: AssetImage('assets/howto.png'),
                        height: 400,
                      )),
                  const SizedBox(height: 30),
                  const Text(
                    "Pour commencer, vous devez renseigner votre clé d'api OpenIA. \n cliquez sur le bouton ci-dessous pour accéder aux paramètres.",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsPage()));
                    },
                    child: const Text("Paramètres"),
                  )
                ]))
          ]))
        ]));
  }
}
