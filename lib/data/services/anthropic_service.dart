import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when the Anthropic API returns an error.
class AnthropicException implements Exception {
  AnthropicException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isAuthError => statusCode == 401;

  @override
  String toString() => 'AnthropicException($statusCode): $message';
}

/// A meal suggestion produced by the AI meal maker.
class MealSuggestion {
  const MealSuggestion({
    required this.title,
    required this.description,
    required this.timeMinutes,
    required this.kcal,
    required this.usedIngredients,
    required this.missingIngredients,
    required this.steps,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    return MealSuggestion(
      title: json['title'] as String,
      description: json['description'] as String,
      timeMinutes: (json['time_minutes'] as num).toInt(),
      kcal: (json['kcal'] as num).toDouble(),
      usedIngredients: (json['used_ingredients'] as List<dynamic>)
          .cast<String>(),
      missingIngredients: (json['missing_ingredients'] as List<dynamic>)
          .cast<String>(),
      steps: (json['steps'] as List<dynamic>).cast<String>(),
    );
  }

  final String title;
  final String description;
  final int timeMinutes;
  final double kcal;
  final List<String> usedIngredients;
  final List<String> missingIngredients;
  final List<String> steps;
}

/// A grocery purchase suggestion produced by the AI.
class GrocerySuggestion {
  const GrocerySuggestion({required this.name, required this.reason});

  factory GrocerySuggestion.fromJson(Map<String, dynamic> json) {
    return GrocerySuggestion(
      name: json['name'] as String,
      reason: json['reason'] as String,
    );
  }

  final String name;
  final String reason;
}

/// Direct client for the Anthropic Messages API (there is no official Dart
/// SDK). The user supplies their own API key (BYOK).
class AnthropicService {
  AnthropicService({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  static const endpoint = 'https://api.anthropic.com/v1/messages';
  static const model = 'claude-opus-4-8';

  final String apiKey;
  final http.Client _client;

  Map<String, String> get _headers => {
    'content-type': 'application/json',
    'x-api-key': apiKey,
    'anthropic-version': '2023-06-01',
  };

  /// Streams a summary of [text] as it is generated (SSE).
  Stream<String> streamArticleSummary({
    required String? title,
    required String text,
    required String language,
  }) async* {
    final request = http.Request('POST', Uri.parse(endpoint))
      ..headers.addAll(_headers)
      ..body = jsonEncode({
        'model': model,
        'max_tokens': 16000,
        'stream': true,
        'system':
            'You are an expert at extracting key information from web articles. '
            'Produce a concise, well-organized summary: a one-sentence TL;DR '
            'first, then short paragraphs or "- " bullet points for the key '
            'facts. Ignore navigation, ads and unrelated content. Plain text '
            'only, no markdown headers. Answer in $language.',
        'messages': [
          {
            'role': 'user',
            'content':
                'Summarize this article${title == null ? '' : ' titled "$title"'}:\n\n$text',
          },
        ],
      });

    final response = await _client.send(request);
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw AnthropicException(
        _errorMessage(body),
        statusCode: response.statusCode,
      );
    }
    yield* parseSseTextDeltas(response.stream.transform(utf8.decoder));
  }

  /// Parses an Anthropic SSE stream into the text deltas it carries.
  /// Exposed for testing.
  static Stream<String> parseSseTextDeltas(Stream<String> input) async* {
    final lines = input.transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue;
      final payload = line.substring(6).trim();
      if (payload.isEmpty || payload == '[DONE]') continue;
      final Map<String, dynamic> event;
      try {
        event = jsonDecode(payload) as Map<String, dynamic>;
      } on FormatException {
        continue;
      }
      switch (event['type']) {
        case 'content_block_delta':
          final delta = event['delta'] as Map<String, dynamic>?;
          if (delta?['type'] == 'text_delta') {
            yield delta!['text'] as String;
          }
        case 'error':
          final error = event['error'] as Map<String, dynamic>?;
          throw AnthropicException(
            (error?['message'] as String?) ?? 'Unknown streaming error',
          );
      }
    }
  }

  /// Asks for meal suggestions based on what is in the kitchen.
  /// Uses structured outputs so the response is guaranteed valid JSON.
  Future<List<MealSuggestion>> suggestMeals({
    required List<Map<String, Object?>> pantry,
    required double remainingKcal,
    required String language,
  }) async {
    final result = await _structuredRequest(
      system:
          'You are a pragmatic home-cooking assistant for a lazy person who is '
          'addicted to sugar and quick meals, and wants to eat healthier with '
          'minimal effort. Suggest simple, realistic meals that mostly use '
          'what is already in the kitchen. Prefer few steps and short cooking '
          'times. Answer in $language.',
      userContent:
          'Here is my kitchen inventory as JSON (amount_left_percent is how '
          'much of the package remains):\n${jsonEncode(pantry)}\n\n'
          'I have about ${remainingKcal.round()} kcal left for today. '
          'Suggest exactly 3 healthy, low-effort meals I can make right now. '
          'Only list an ingredient in missing_ingredients if I truly need to '
          'buy it (assume I have water, salt, pepper and basic oil).',
      schema: {
        'type': 'object',
        'properties': {
          'meals': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'title': {'type': 'string'},
                'description': {'type': 'string'},
                'time_minutes': {'type': 'integer'},
                'kcal': {'type': 'number'},
                'used_ingredients': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
                'missing_ingredients': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
                'steps': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
              },
              'required': [
                'title',
                'description',
                'time_minutes',
                'kcal',
                'used_ingredients',
                'missing_ingredients',
                'steps',
              ],
              'additionalProperties': false,
            },
          },
        },
        'required': ['meals'],
        'additionalProperties': false,
      },
    );
    return (result['meals'] as List<dynamic>)
        .map((m) => MealSuggestion.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Asks what should be bought at the store, given the pantry state and
  /// recent consumption habits.
  Future<List<GrocerySuggestion>> suggestGroceries({
    required List<Map<String, Object?>> pantry,
    required List<String> recentlyEaten,
    required List<String> alreadyOnList,
    required String language,
  }) async {
    final result = await _structuredRequest(
      system:
          'You are a grocery-planning assistant for a lazy person trying to '
          'eat healthier. Suggest practical items to buy so that healthy, '
          'low-effort meals are always possible. Favor staples and fresh '
          'items that complement what they own. Answer in $language.',
      userContent:
          'Kitchen inventory:\n${jsonEncode(pantry)}\n\n'
          'Recently eaten: ${jsonEncode(recentlyEaten)}\n'
          'Already on my shopping list: ${jsonEncode(alreadyOnList)}\n\n'
          'Suggest up to 8 items I should buy (do not repeat items already on '
          'the list), each with a very short reason.',
      schema: {
        'type': 'object',
        'properties': {
          'items': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string'},
                'reason': {'type': 'string'},
              },
              'required': ['name', 'reason'],
              'additionalProperties': false,
            },
          },
        },
        'required': ['items'],
        'additionalProperties': false,
      },
    );
    return (result['items'] as List<dynamic>)
        .map((i) => GrocerySuggestion.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> _structuredRequest({
    required String system,
    required String userContent,
    required Map<String, Object?> schema,
  }) async {
    final response = await _client
        .post(
          Uri.parse(endpoint),
          headers: _headers,
          body: jsonEncode({
            'model': model,
            'max_tokens': 8000,
            'system': system,
            'output_config': {
              'format': {'type': 'json_schema', 'schema': schema},
            },
            'messages': [
              {'role': 'user', 'content': userContent},
            ],
          }),
        )
        .timeout(const Duration(minutes: 5));

    if (response.statusCode != 200) {
      throw AnthropicException(
        _errorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
    return extractStructuredJson(response.body);
  }

  /// Pulls the JSON payload out of a structured-output response body.
  /// Exposed for testing.
  static Map<String, dynamic> extractStructuredJson(String responseBody) {
    final body = jsonDecode(responseBody) as Map<String, dynamic>;
    if (body['stop_reason'] == 'refusal') {
      throw AnthropicException('The model declined to answer this request.');
    }
    final content = (body['content'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final textBlock = content.firstWhere(
      (b) => b['type'] == 'text',
      orElse: () => throw AnthropicException('No text block in response'),
    );
    return jsonDecode(textBlock['text'] as String) as Map<String, dynamic>;
  }

  static String _errorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      return (error?['message'] as String?) ?? body;
    } on FormatException {
      return body;
    }
  }
}
