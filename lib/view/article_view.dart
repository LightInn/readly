import 'package:flutter/material.dart';
import 'package:rid/model/article_controller.dart';
import 'package:rid/page/images_page.dart';
import 'package:rid/page/liste_page.dart';
import 'package:rid/page/settings_page.dart';

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
        title: Text(controller.pageTitle.toString() == "null"
            ? "Rid"
            : controller.pageTitle.toString()),
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
                    : controller.synthese != null && controller.synthese != ""
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  controller.pageTitle.toString(),
                                  style: const TextStyle(
                                    fontSize: 26.0,
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // TODO : Interpreter le markdown

                                // MarkdownWidget(
                                //     data: controller.synthese!,
                                //     config: MarkdownConfig(configs: [
                                //       PreConfig(theme: a11yLightTheme),
                                //     ])),
                                Text(
                                  controller.synthese!,
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
          controller.listImages == null || controller.listImages!.isEmpty
              ? const SizedBox(height: 0)
              : FloatingActionButton.large(
                  onPressed: () {
                    // Add your onPressed code here!
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImagesPage(
                                  listImages: controller.listImages,
                                )));
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  splashColor: Colors.black45,
                  child: const Icon(Icons.photo_album_outlined),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat);
}
