import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readly/page/settings_page.dart';
import 'package:readly/page/simplify_page.dart';
import 'package:readly/page/welcome_page.dart';
import 'package:readly/services/hook_service.dart';
import 'package:share_handler/share_handler.dart';

// The WelcomePage is the first page of the app. it have the "how to" information and have a button to go to the settings page
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pageRedirect();
    welcomeVerification();
  }

  void pageRedirect() async {
    await HookService.getInitialSharedMedia(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Readly"),
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
                    "Read a web page and get a summary!",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // search bar looking like google search bar

                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Enter the url of the article to summarize",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "It will extract the main information and images from the article for you !",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // search button looking really good and nice
                  ElevatedButton(
                    onPressed: () {
                      var shared = new SharedMedia();
                      shared.content = searchController.text;

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SimplifyPage(
                                    sharedmedia: shared,
                                  )));
                    },
                    child: const Text("Search"),
                  ),
                ]))
          ]))
        ]));
  }

  Future<void> welcomeVerification() async {
    // check  secure storage for the welcome page
    // if it's the first time, show the welcome page
    // if it's not the first time, show the search page
    // if the user has already seen the welcome page, show the search page

    var storage = new FlutterSecureStorage();
    var welcome = await storage.read(key: "welcome");

    if (welcome == null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const WelcomePage()));
    }
  }
}
