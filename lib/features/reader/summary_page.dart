import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/db/database.dart';
import '../../data/services/anthropic_service.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

enum _Status { extracting, streaming, done, error }

/// Shows a saved summary (when [savedArticleId] is set) or runs the
/// extract → stream-summary pipeline for [url].
class SummaryPage extends ConsumerStatefulWidget {
  const SummaryPage({super.key, required this.url, this.savedArticleId});

  final String url;
  final int? savedArticleId;

  @override
  ConsumerState<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends ConsumerState<SummaryPage> {
  _Status _status = _Status.extracting;
  String _title = '';
  String _summary = '';
  String _error = '';
  bool _needsApiKey = false;
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    if (widget.savedArticleId != null) {
      unawaited(_loadSaved());
    } else {
      unawaited(_run());
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final article = await ref
        .read(databaseProvider)
        .articleById(widget.savedArticleId!);
    if (!mounted) return;
    setState(() {
      if (article == null) {
        _status = _Status.error;
        _error = 'This summary was deleted.';
      } else {
        _title = article.title;
        _summary = article.summary;
        _status = _Status.done;
      }
    });
  }

  Future<void> _run() async {
    setState(() {
      _status = _Status.extracting;
      _summary = '';
      _error = '';
      _needsApiKey = false;
    });

    final anthropic = await ref.read(anthropicServiceProvider.future);
    if (!mounted) return;
    if (anthropic == null) {
      setState(() {
        _status = _Status.error;
        _needsApiKey = true;
        _error =
            'Add your Anthropic API key in settings to summarize articles.';
      });
      return;
    }

    try {
      final settings = await ref.read(settingsProvider.future);
      final article = await ref
          .read(articleExtractorProvider)
          .extract(widget.url);
      if (!mounted) return;
      if (article.text.trim().isEmpty) {
        throw Exception('No readable text found on this page.');
      }
      setState(() {
        _title = article.title;
        _status = _Status.streaming;
      });

      _subscription = anthropic
          .streamArticleSummary(
            title: article.title,
            text: article.text,
            language: settings.language,
          )
          .listen(
            (delta) => setState(() => _summary += delta),
            onError: (Object e) => setState(() {
              _status = _Status.error;
              _error = e is AnthropicException ? e.message : '$e';
            }),
            onDone: () async {
              if (!mounted) return;
              setState(() => _status = _Status.done);
              if (_summary.trim().isNotEmpty) {
                await ref
                    .read(databaseProvider)
                    .saveArticle(
                      ArticlesCompanion.insert(
                        url: widget.url,
                        title: _title,
                        summary: _summary,
                      ),
                    );
              }
            },
          );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _Status.error;
        _error = e is AnthropicException ? e.message : '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          IconButton(
            tooltip: 'Open original',
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => launchUrl(
              Uri.parse(widget.url),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: switch (_status) {
        _Status.extracting => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Reading the page…'),
            ],
          ),
        ),
        _Status.error => EmptyState(
          icon: _needsApiKey ? Icons.key_off : Icons.error_outline,
          title: 'Could not summarize',
          message: _error,
          action: _needsApiKey
              ? FilledButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Open settings'),
                  onPressed: () => context.push('/settings'),
                )
              : FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                  onPressed: _run,
                ),
        ),
        _Status.streaming || _Status.done => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Text(
              _title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              Uri.tryParse(widget.url)?.host ?? widget.url,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            SelectableText(
              _summary,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            if (_status == _Status.streaming)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
      },
    );
  }
}
