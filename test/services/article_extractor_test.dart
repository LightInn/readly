import 'package:flutter_test/flutter_test.dart';
import 'package:readly/data/services/article_extractor.dart';

void main() {
  group('parseProxyResponse', () {
    test('reads title and textContent from the readability proxy', () {
      final article = ArticleExtractor.parseProxyResponse(
        '{"title":"Big News","textContent":"The clean article text.",'
        '"content":"<p>The clean article text.</p>"}',
        fallbackTitle: 'https://example.com',
      );
      expect(article.title, 'Big News');
      expect(article.text, 'The clean article text.');
    });

    test('falls back to the URL when the title is missing', () {
      final article = ArticleExtractor.parseProxyResponse(
        '{"textContent":"Some text."}',
        fallbackTitle: 'https://example.com/x',
      );
      expect(article.title, 'https://example.com/x');
    });

    test('throws when the proxy returns no text', () {
      expect(
        () => ArticleExtractor.parseProxyResponse(
          '{"title":"Empty","textContent":""}',
          fallbackTitle: 'u',
        ),
        throwsException,
      );
    });
  });

  test('extracts title and paragraphs, ignoring scripts and navigation', () {
    const source = '''
<html>
  <head><title>Big News Story</title><script>evil()</script></head>
  <body>
    <nav><a href="/">Home</a><a href="/about">About</a></nav>
    <article>
      <h1>Big News Story</h1>
      <p>This is the first paragraph of the article, long enough to count as content.</p>
      <p>Second paragraph with additional details about the important event described.</p>
    </article>
    <footer>Copyright notice and useless links everywhere</footer>
  </body>
</html>''';

    final article = ArticleExtractor.extractFromHtml(
      source,
      fallbackTitle: 'https://example.com',
    );
    expect(article.title, 'Big News Story');
    expect(article.text, contains('first paragraph'));
    expect(article.text, contains('Second paragraph'));
    expect(article.text, isNot(contains('evil')));
    expect(article.text, isNot(contains('Copyright')));
  });

  test('falls back to body text and the given title', () {
    const source = '<html><body>Just some short raw text</body></html>';
    final article = ArticleExtractor.extractFromHtml(
      source,
      fallbackTitle: 'https://example.com/x',
    );
    expect(article.title, 'https://example.com/x');
    expect(article.text, 'Just some short raw text');
  });

  test('caps extremely long articles', () {
    final source = '<html><body><p>${'word ' * 30000}</p></body></html>';
    final article = ArticleExtractor.extractFromHtml(
      source,
      fallbackTitle: 't',
    );
    expect(article.text.length, lessThanOrEqualTo(ArticleExtractor.maxChars));
  });
}
