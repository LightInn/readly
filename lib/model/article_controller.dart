class ArticleController {
  final bool isLoading;
  final String? synthese;
  final String? pageTitle;

  List<String>? listImages;

  final bool isOpenAI;

  ArticleController(
      this.isLoading, this.synthese, this.pageTitle, this.listImages, this.isOpenAI);
}
