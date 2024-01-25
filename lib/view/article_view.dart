import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rid/model/article_controller.dart';
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

              // ...
            ],
          ),
        ),
        const Center(
          child: Text(
            "Images : ",
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Montserrat',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: controller.listImages == null
              ? SizedBox(
                  width: 150,
                  child: Image.network(
                      "https://static.vecteezy.com/system/resources/previews/010/313/693/original/emoji-feel-good-smile-happy-file-png.png"),
                )
              : ListView.builder(
                  itemCount: controller.listImages?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 150,
                      child: Image.network(controller.listImages![index],
                          fit: BoxFit.cover, errorBuilder:
                              (BuildContext context, Object exception,
                                  StackTrace? stackTrace) {
                        return const Text('error loading image');
                      }),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}
