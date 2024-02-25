class Article {
  late String url;
  String? title;
  List<String>? listImages;
  String? synthese;
  late DateTime date;

  Article({
    required this.url,
    this.title,
    this.listImages,
    this.synthese,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}
