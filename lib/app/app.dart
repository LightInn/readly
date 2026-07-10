import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_handler/share_handler.dart';

import '../data/services/widget_sync.dart';
import '../providers.dart';
import 'router.dart';
import 'theme.dart';

class ReadlyApp extends StatefulWidget {
  const ReadlyApp({super.key});

  /// Pulls the first http(s) URL out of a shared text blob.
  static String? extractUrl(String text) {
    return RegExp(r'https?://\S+').firstMatch(text)?.group(0);
  }

  @override
  State<ReadlyApp> createState() => _ReadlyAppState();
}

class _ReadlyAppState extends State<ReadlyApp> {
  late final GoRouter _router;
  StreamSubscription<SharedMedia>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
    _initShareIntents();
  }

  Future<void> _initShareIntents() async {
    final handler = ShareHandlerPlatform.instance;
    _shareSubscription = handler.sharedMediaStream.listen(
      _handleShare,
      // Platform without share support (tests, desktop) — ignore.
      onError: (Object _) {},
    );
    try {
      final initial = await handler.getInitialSharedMedia();
      if (initial != null) _handleShare(initial);
    } on Exception {
      // Platform without share support (tests, desktop) — ignore.
    }
  }

  void _handleShare(SharedMedia media) {
    final url = ReadlyApp.extractUrl(media.content ?? '');
    if (url == null) return;
    _router.go('/read');
    _router.push(
      Uri(path: '/read/summary', queryParameters: {'url': url}).toString(),
    );
  }

  @override
  void dispose() {
    unawaited(_shareSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Readly',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      routerConfig: _router,
      builder: (context, child) =>
          _WidgetSyncListener(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Keeps the Android home-screen widget in sync: whenever today's entries or
/// the streak stats change, the headline numbers are pushed to the widget.
class _WidgetSyncListener extends ConsumerWidget {
  const _WidgetSyncListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(todayEntriesProvider, (_, _) => _push(ref));
    ref.listen(progressStatsProvider, (_, _) => _push(ref));
    return child;
  }

  void _push(WidgetRef ref) {
    final settings = ref.read(settingsProvider).value;
    final entries = ref.read(todayEntriesProvider).value;
    final data = ref.read(progressStatsProvider).value;
    if (settings == null || entries == null || data == null) return;
    final consumed = entries.fold<double>(0, (sum, e) => sum + e.kcal);
    final (stats, _) = data;
    unawaited(
      WidgetSync.push(
        kcalLeft: (settings.dailyKcalGoal - consumed).round(),
        streakDays: stats.streakDays,
        kgLost: stats.kgLost,
      ),
    );
  }
}
