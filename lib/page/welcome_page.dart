import 'package:flutter/material.dart';
import 'package:rid/page/settings_page.dart';
import 'package:rid/services/hook_service.dart';

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
                    "Welcome on Rid !",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Rid is an application that generates text summaries from press articles.",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "All you have to do is share the url of an article with the application",
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
                    "To get started, you'll need to enter your OpenIA api key.\n Click on the button below to access the settings.",
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
                    child: const Text("Settings"),
                  )
                ]))
          ]))
        ]));
  }
}
