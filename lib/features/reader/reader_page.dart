import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import '../../widgets/common.dart';

class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({super.key});

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _summarize() {
    var url = _urlController.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) url = 'https://$url';
    _urlController.clear();
    context.push(
      Uri(path: '/read/summary', queryParameters: {'url': url}).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final articles = ref.watch(articlesProvider).value ?? [];
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Read'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'Paste an article URL…',
              prefixIcon: const Icon(Icons.link),
              suffixIcon: IconButton(
                icon: const Icon(Icons.auto_awesome),
                onPressed: _summarize,
              ),
            ),
            onSubmitted: (_) => _summarize(),
          ),
          const SizedBox(height: 12),
          Card(
            color: scheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.share, color: scheme.onSecondaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: share any page from your browser to Readly to '
                      'summarize it instantly.',
                      style: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (articles.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.auto_stories,
                title: 'No summaries yet',
                message:
                    'Summaries of the articles you share will pile up here.',
              ),
            )
          else ...[
            const SectionHeader('History'),
            Card(
              child: Column(
                children: [
                  for (final article in articles)
                    Dismissible(
                      key: ValueKey('article-${article.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        color: scheme.errorContainer,
                        child: const Icon(Icons.delete_outline),
                      ),
                      onDismissed: (_) =>
                          ref.read(databaseProvider).deleteArticle(article.id),
                      child: ListTile(
                        leading: const Icon(Icons.article_outlined),
                        title: Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          Uri.tryParse(article.url)?.host ?? article.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => context.push(
                          Uri(
                            path: '/read/summary',
                            queryParameters: {
                              'url': article.url,
                              'articleId': article.id.toString(),
                            },
                          ).toString(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
