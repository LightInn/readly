

class Synthese {
  late String url;
  String? title;
  List<String>? listImages;
  String? synthese;
  late DateTime date;

  Synthese({
    required this.url,
    this.title,
    this.listImages,
    this.synthese,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}
