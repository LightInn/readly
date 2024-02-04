import 'package:animated_image_list/AnimatedImageList.dart';
import 'package:flutter/material.dart';

class ImagesPage extends StatefulWidget {
  final List<String>? listImages;

  const ImagesPage({super.key, this.listImages});

  @override
  _ImagesPageState createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedImageList(
        images: widget.listImages ?? [],
        builder: (context, index, progress) {
          return Positioned.directional(
              textDirection: TextDirection.ltr,
              bottom: 15,
              start: 25,
              child: const Opacity(
                opacity: 0,
                child: Text(''),
              ));
        },
        scrollDirection: Axis.vertical,
        itemExtent: 100,
        maxExtent: 400,
      ),
    );
  }
}
