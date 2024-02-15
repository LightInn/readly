class ArticleController {
  final bool isLoading;
  final String? synthese;
  final String? pageTitle;

  final String? url;

  List<String>? listImages;

  final bool isOpenAI;

  ArticleController(
      this.isLoading, this.synthese, this.pageTitle, this.listImages, this.isOpenAI, this.url);
}
