class Article {
  late String url;
  String? title;
  List<String>? listImagesUrls;
  String? content;
  late DateTime date;

  Article({
    required this.url,
    this.title,
    this.listImagesUrls,
    this.content,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}
