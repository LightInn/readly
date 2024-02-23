class ArticleController {
  final bool isLoading;
  final bool isOpenAI;
  final String? content;
  final String? title;
  final String? url;
  List<String>? imagesList;

  ArticleController(
      this.isLoading, //
      this.content, //
      this.title, //
      this.imagesList, //
      this.isOpenAI, //
      this.url //
      );
}
