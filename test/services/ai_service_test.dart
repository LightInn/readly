import 'package:flutter_test/flutter_test.dart';
import 'package:readly/data/services/ai_service.dart';

void main() {
  group('extractJson', () {
    test('parses a plain JSON object', () {
      expect(AiService.extractJson('{"meals":[]}'), {'meals': <Object?>[]});
    });

    test('strips markdown code fences', () {
      expect(AiService.extractJson('```json\n{"items":[]}\n```'), {
        'items': <Object?>[],
      });
    });

    test('tolerates prose around the JSON object', () {
      expect(
        AiService.extractJson('Sure! Here you go: {"items":[{"name":"x"}]}'),
        {
          'items': [
            {'name': 'x'},
          ],
        },
      );
    });

    test('throws a readable error on empty or non-JSON answers', () {
      expect(() => AiService.extractJson(''), throwsA(isA<AiException>()));
      expect(
        () => AiService.extractJson('I cannot answer that.'),
        throwsA(isA<AiException>()),
      );
      expect(
        () => AiService.extractJson('{"broken": '),
        throwsA(isA<AiException>()),
      );
    });
  });

  test('MealSuggestion.fromJson maps every field', () {
    final meal = MealSuggestion.fromJson({
      'title': 'Omelette',
      'description': 'Fast protein.',
      'time_minutes': 10,
      'kcal': 350.5,
      'used_ingredients': ['eggs', 'cheese'],
      'missing_ingredients': ['chives'],
      'steps': ['Beat eggs', 'Cook'],
    });
    expect(meal.title, 'Omelette');
    expect(meal.timeMinutes, 10);
    expect(meal.kcal, 350.5);
    expect(meal.usedIngredients, hasLength(2));
    expect(meal.missingIngredients, ['chives']);
    expect(meal.steps, hasLength(2));
  });

  test('GrocerySuggestion.fromJson maps name and reason', () {
    final item = GrocerySuggestion.fromJson({
      'name': 'Greek yogurt',
      'reason': 'Healthy snack base',
    });
    expect(item.name, 'Greek yogurt');
    expect(item.reason, 'Healthy snack base');
  });
}
