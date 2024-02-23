import 'package:flutter/material.dart';
import 'package:readly/model/article_controller.dart';
import 'package:readly/page/generation_page.dart';
import 'package:readly/page/images_page.dart';
import 'package:readly/page/liste_page.dart';
import 'package:readly/page/settings_page.dart';

Scaffold ArticleView(BuildContext context, ArticleController controller) {
  return Scaffold(
      appBar: AppBar(
        leading: IconButton.outlined(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ListePage()));
            },
            icon: const Icon(Icons.account_tree_outlined)),
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
        title: Text(controller.title.toString() == "null"
            ? "Readly"
            : controller.title.toString()),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 10),
                controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : controller.content != null && controller.content != ""
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  controller.title.toString(),
                                  style: const TextStyle(
                                    fontSize: 26.0,
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  controller.content!,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Text('No data'),
                const SizedBox(height: 120),
                // ...
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        //  FLOAT ACTION FOR IA GENERATION
        controller.isOpenAI
            ? FloatingActionButton(
                onPressed: () {
                  // Add your onPressed code here!
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GenerationPage(
                                articleController: controller,
                              )));
                },
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                splashColor: Colors.black45,
                child: const Icon(Icons.spa_outlined),
              )
            : const SizedBox(),
        const SizedBox(
          height: 10,
        ),

        // FLOAT ACTION FOR IMAGES PAGE

        controller.imagesList == null || controller.imagesList!.isEmpty
            ? const SizedBox()
            : FloatingActionButton(
                onPressed: () {
                  // Add your onPressed code here!
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImagesPage(
                                listImages: controller.imagesList,
                              )));
                },
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                splashColor: Colors.black45,
                child: const Icon(Icons.photo_album_outlined),
              ),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat //
      );
}
