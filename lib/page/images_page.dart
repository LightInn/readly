import 'package:animated_image_list/AnimatedImageList.dart';
import 'package:flutter/material.dart';

class ImagesPage extends StatefulWidget {
  final List<String>? listImages;

  const ImagesPage({Key? key, this.listImages}) : super(key: key);

  @override
  _ImagesPageState createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedImageList(
      images: widget.listImages ?? [],
      builder: (context, index, progress) {
        return Positioned.directional(
            textDirection: TextDirection.ltr,
            bottom: 15,
            start: 25,
            child: Opacity(
              opacity: progress > 1 ? (2 - progress) : progress,
              child: const Text(
                'Anonymous',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w500),
              ),
            ));
      },
      scrollDirection: Axis.vertical,
      itemExtent: 100,
      maxExtent: 400,
    );
  }
}
