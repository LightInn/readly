class ArticleController {
  final bool isLoading;
  final bool isOpenAI;
  final String? content;
  final String? title;
  final String? url;
  List<String>? listImagesUrls;

  ArticleController(
      this.isLoading, //
      this.content, //
      this.title, //
      this.listImagesUrls, //
      this.isOpenAI, //
      this.url //
      );
}
