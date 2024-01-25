class ArticleController {
  final bool isLoading;
  final String? synthese;
  final String? pageTitle;

  List<String>? listImages;

  ArticleController(
      this.isLoading, this.synthese, this.pageTitle, this.listImages);
}
