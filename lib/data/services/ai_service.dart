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
  const GrocerySuggestion({
    required this.name,
    required this.reason,
    this.quantity,
    this.priceEur,
  });

  factory GrocerySuggestion.fromJson(Map<String, dynamic> json) {
    return GrocerySuggestion(
      name: json['name'] as String,
      reason: json['reason'] as String,
      quantity: json['quantity'] as String?,
      priceEur: (json['price_eur'] as num?)?.toDouble(),
    );
  }

  final String name;
  final String reason;

  /// Suggested amount to buy, e.g. "500 g" or "6 pots".
  final String? quantity;

  /// Rough French-supermarket price estimate.
  final double? priceEur;
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

  /// The owner's profile, injected into the food prompts so suggestions fit
  /// his actual life. Personal app — hardcoding this is a feature, not a bug.
  /// Prompts are written in French on purpose: the model's French culinary
  /// vector space is where the good, realistic food ideas live.
  static const _userProfile =
      'Profil du propriétaire : homme de 25 ans, 120 kg, travail de bureau '
      'sédentaire, en déficit calorique volontaire (~1900 kcal/jour pour une '
      'dépense estimée à ~2200). Il est déjà descendu à 96 kg puis a repris du '
      'poids en retombant dans les excès — l\'enjeu est la DURABILITÉ. Accro '
      'au sucre et aux produits transformés (chips au vinaigre, fromage, '
      'barres chocolatées, plats gras). Déteste éplucher, découper et les '
      'recettes longues. Le midi en semaine, il mange souvent au restaurant '
      'avec des collègues (poké, curry, bento…). Le soir après le travail, '
      'gros risque de craquage sur du sucré ou du gras : des dîners '
      'rassasiants, riches en protéines et pauvres en sucre sont essentiels.';

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
          'Tu es un assistant de cuisine pragmatique, ancré dans la culture '
          'gastronomique française : simple, bon, réaliste. $_userProfile\n'
          'Propose des plats qui utilisent en priorité ce qui est déjà dans '
          'la cuisine, en respectant les quantités réellement restantes. '
          'Donne la priorité aux ingrédients périssables pour éviter le '
          'gaspillage. Équilibre le reste de la journée par rapport à ce qui '
          'a déjà été mangé (plus léger et plus de légumes après une journée '
          'chargée ou sucrée). Très peu d\'étapes, temps courts, protéines '
          'rassasiantes, peu de sucre. Réponds en $language, au format JSON.',
      userContent:
          'Voici l\'inventaire de ma cuisine en JSON (amount_left_percent ou '
          'units_left indiquent ce qui reste de chaque paquet ; '
          'perishable = à consommer en priorité) :\n${jsonEncode(pantry)}\n\n'
          'Ce que j\'ai déjà mangé aujourd\'hui '
          '(${consumedKcal.round()} kcal consommées sur un objectif de '
          '${dailyGoalKcal.round()} kcal) :\n'
          '${eatenToday.isEmpty ? 'rien pour l\'instant' : jsonEncode(eatenToday)}\n\n'
          'Il est ${DateTime.now().hour} h et il me reste environ '
          '${remainingKcal.round()} kcal pour aujourd\'hui. Propose exactement '
          '3 repas sains et sans effort, adaptés à ce moment de la journée, '
          'que je peux faire maintenant. Ne mets un ingrédient dans '
          'missing_ingredients que si je dois vraiment l\'acheter (je possède '
          'eau, sel, poivre et huile de base).',
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
          'Tu es un assistant de courses ancré dans la culture gastronomique '
          'française. $_userProfile\n'
          'Suggère des achats pratiques pour que des repas sains et sans '
          'effort soient toujours possibles : des basiques qui se gardent, du '
          'frais facile à utiliser sans préparation, et des alternatives '
          'moins sucrées / moins grasses à ses envies habituelles. Réponds '
          'en $language, au format JSON.',
      userContent:
          'Inventaire de la cuisine :\n${jsonEncode(pantry)}\n\n'
          'Mangé récemment : ${jsonEncode(recentlyEaten)}\n'
          'Déjà sur ma liste de courses : ${jsonEncode(alreadyOnList)}\n\n'
          'Suggère jusqu\'à 8 articles à acheter (sans répéter ceux déjà sur '
          'la liste), chacun avec : une raison très courte, la quantité '
          'conseillée (ex "500 g", "6 pots") et un prix estimé en euros dans '
          'un supermarché français (approximation grossière acceptée).',
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
                'quantity': {'type': 'string'},
                'price_eur': {'type': 'number'},
              },
              'required': ['name', 'reason', 'quantity', 'price_eur'],
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
