import 'dart:async';
import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';

/// Thrown when the OpenAI API returns an error.
class AiException implements Exception {
  AiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isAuthError => statusCode == 401;

  @override
  String toString() => 'AiException($statusCode): $message';
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

/// Client for the OpenAI Chat Completions API through `dart_openai`.
/// The user supplies their own API key (BYOK).
class AiService {
  AiService({required String apiKey}) {
    OpenAI.apiKey = apiKey;
    OpenAI.requestsTimeOut = const Duration(minutes: 5);
  }

  /// Cheap, fast router model — plenty for summaries and meal ideas.
  static const model = 'gpt-5-nano';

  static OpenAIChatCompletionChoiceMessageModel _message(
    OpenAIChatMessageRole role,
    String text,
  ) {
    return OpenAIChatCompletionChoiceMessageModel(
      role: role,
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(text)],
    );
  }

  /// Streams a summary of [text] as it is generated.
  Stream<String> streamArticleSummary({
    required String? title,
    required String text,
    required String language,
  }) {
    final stream = OpenAI.instance.chat.createStream(
      model: model,
      messages: [
        _message(
          OpenAIChatMessageRole.system,
          'You are an expert at extracting key information from web articles. '
          'Produce a concise, well-organized summary: a one-sentence TL;DR '
          'first, then short paragraphs or "- " bullet points for the key '
          'facts. Ignore navigation, ads and unrelated content. Plain text '
          'only, no markdown headers. Answer in $language.',
        ),
        _message(
          OpenAIChatMessageRole.user,
          'Summarize this article${title == null ? '' : ' titled "$title"'}:'
          '\n\n$text',
        ),
      ],
    );

    return stream
        .map((event) {
          if (event.choices.isEmpty) return '';
          final content = event.choices.first.delta.content;
          if (content == null) return '';
          return content.map((item) => item?.text ?? '').join();
        })
        .where((delta) => delta.isNotEmpty)
        .handleError((Object e) => throw _wrap(e));
  }

  /// Asks for meal suggestions based on what is in the kitchen, how much of
  /// it remains, and what was already eaten today.
  /// Uses structured outputs so the response is guaranteed valid JSON.
  Future<List<MealSuggestion>> suggestMeals({
    required List<Map<String, Object?>> pantry,
    required List<Map<String, Object?>> eatenToday,
    required double consumedKcal,
    required double dailyGoalKcal,
    required double remainingKcal,
    required String language,
  }) async {
    final result = await _structuredRequest(
      system:
          'You are a pragmatic home-cooking assistant for a lazy person who is '
          'addicted to sugar and quick meals, and wants to eat healthier with '
          'minimal effort. Suggest simple, realistic meals that mostly use '
          'what is already in the kitchen, in quantities that respect what is '
          'actually left. Give priority to perishable ingredients so nothing '
          'goes to waste. Balance the rest of the day nutritionally against '
          'what was already eaten (e.g. lighter and more vegetables after a '
          'heavy or sugary day). Prefer few steps and short cooking times. '
          'Answer in $language, as JSON.',
      userContent:
          'Here is my kitchen inventory as JSON (amount_left_percent or '
          'units_left say how much of each package remains; perishable items '
          'should be used first):\n${jsonEncode(pantry)}\n\n'
          'What I already ate today (${consumedKcal.round()} kcal consumed of '
          'my ${dailyGoalKcal.round()} kcal daily goal):\n'
          '${eatenToday.isEmpty ? 'nothing yet' : jsonEncode(eatenToday)}\n\n'
          'I have about ${remainingKcal.round()} kcal left for today. '
          'Suggest exactly 3 healthy, low-effort meals I can make right now. '
          'Only list an ingredient in missing_ingredients if I truly need to '
          'buy it (assume I have water, salt, pepper and basic oil).',
      schemaName: 'meal_suggestions',
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
          'items that complement what they own. Answer in $language, as JSON.',
      userContent:
          'Kitchen inventory:\n${jsonEncode(pantry)}\n\n'
          'Recently eaten: ${jsonEncode(recentlyEaten)}\n'
          'Already on my shopping list: ${jsonEncode(alreadyOnList)}\n\n'
          'Suggest up to 8 items I should buy (do not repeat items already on '
          'the list), each with a very short reason.',
      schemaName: 'grocery_suggestions',
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
    required String schemaName,
    required Map<String, Object?> schema,
  }) async {
    final OpenAIChatCompletionModel response;
    try {
      response = await OpenAI.instance.chat.create(
        model: model,
        messages: [
          _message(OpenAIChatMessageRole.system, system),
          _message(OpenAIChatMessageRole.user, userContent),
        ],
        responseFormat: {
          'type': 'json_schema',
          'json_schema': {'name': schemaName, 'strict': true, 'schema': schema},
        },
      );
    } catch (e) {
      throw _wrap(e);
    }

    if (response.choices.isEmpty) {
      throw AiException('The model returned an empty response.');
    }
    final content = response.choices.first.message.content;
    final text = content?.map((item) => item.text ?? '').join() ?? '';
    return extractJson(text);
  }

  /// Pulls a JSON object out of a model answer, tolerating code fences and
  /// surrounding prose. Exposed for testing.
  static Map<String, dynamic> extractJson(String text) {
    var candidate = text.trim();
    if (candidate.isEmpty) {
      throw AiException('The model returned an empty response.');
    }
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(candidate);
    if (fence != null) candidate = fence.group(1)!.trim();
    if (!candidate.startsWith('{')) {
      final start = candidate.indexOf('{');
      final end = candidate.lastIndexOf('}');
      if (start == -1 || end <= start) {
        throw AiException('The model did not answer with JSON.');
      }
      candidate = candidate.substring(start, end + 1);
    }
    try {
      return jsonDecode(candidate) as Map<String, dynamic>;
    } on FormatException {
      throw AiException('The model answered with invalid JSON.');
    }
  }

  static AiException _wrap(Object e) {
    if (e is AiException) return e;
    if (e is RequestFailedException) {
      return AiException(e.message, statusCode: e.statusCode);
    }
    return AiException(e.toString());
  }
}
