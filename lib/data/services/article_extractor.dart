import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

/// The readable content pulled out of a web page.
class ExtractedArticle {
  const ExtractedArticle({required this.title, required this.text});

  final String title;
  final String text;
}

/// Fetches a web page and extracts its readable text in-app.
/// (Replaces the old dependency on the readly.lightin.io readability API —
/// Claude does the heavy lifting on the extracted text anyway.)
class ArticleExtractor {
  ArticleExtractor({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Characters beyond this are dropped before sending to the model.
  static const maxChars = 60000;

  Future<ExtractedArticle> extract(String url) async {
    final response = await _client
        .get(
          Uri.parse(url),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) '
                'Chrome/126.0 Mobile Safari/537.36',
          },
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Could not fetch the page (HTTP ${response.statusCode})');
    }
    return extractFromHtml(response.body, fallbackTitle: url);
  }

  /// Pure HTML → readable text extraction. Exposed for testing.
  static ExtractedArticle extractFromHtml(
    String htmlSource, {
    required String fallbackTitle,
  }) {
    final document = html_parser.parse(htmlSource);

    // Remove non-content elements.
    for (final selector in [
      'script',
      'style',
      'noscript',
      'nav',
      'header',
      'footer',
      'aside',
      'form',
      'iframe',
    ]) {
      for (final node in document.querySelectorAll(selector)) {
        node.remove();
      }
    }

    final title = document.querySelector('title')?.text.trim();
    final root =
        document.querySelector('article') ??
        document.querySelector('main') ??
        document.body;

    final text = _readableText(root);
    return ExtractedArticle(
      title: (title == null || title.isEmpty) ? fallbackTitle : title,
      text: text.length > maxChars ? text.substring(0, maxChars) : text,
    );
  }

  static String _readableText(dom.Element? root) {
    if (root == null) return '';
    final blocks = root.querySelectorAll('p, h1, h2, h3, h4, li, blockquote');
    final parts = <String>[];
    for (final block in blocks) {
      final text = block.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.length > 30 || (block.localName?.startsWith('h') ?? false)) {
        if (text.isNotEmpty) parts.add(text);
      }
    }
    if (parts.isEmpty) {
      return root.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    return parts.join('\n\n');
  }
}
