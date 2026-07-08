import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:readly/data/services/anthropic_service.dart';

void main() {
  group('parseSseTextDeltas', () {
    Stream<String> sse(List<String> lines) =>
        Stream.fromIterable(lines.map((l) => '$l\n'));

    test('yields text deltas and ignores other events', () async {
      final deltas = await AnthropicService.parseSseTextDeltas(
        sse([
          'event: message_start',
          'data: {"type":"message_start","message":{"id":"msg_1"}}',
          '',
          'event: content_block_delta',
          'data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}',
          'event: content_block_delta',
          'data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" world"}}',
          'event: message_stop',
          'data: {"type":"message_stop"}',
        ]),
      ).toList();
      expect(deltas.join(), 'Hello world');
    });

    test('ignores thinking deltas', () async {
      final deltas = await AnthropicService.parseSseTextDeltas(
        sse([
          'data: {"type":"content_block_delta","index":0,"delta":{"type":"thinking_delta","thinking":"hmm"}}',
          'data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"ok"}}',
        ]),
      ).toList();
      expect(deltas, ['ok']);
    });

    test('throws on error events', () {
      expect(
        AnthropicService.parseSseTextDeltas(
          sse([
            'data: {"type":"error","error":{"type":"overloaded_error","message":"Overloaded"}}',
          ]),
        ).toList(),
        throwsA(
          isA<AnthropicException>().having(
            (e) => e.message,
            'message',
            'Overloaded',
          ),
        ),
      );
    });
  });

  group('extractStructuredJson', () {
    test('parses the JSON text block', () {
      final body = jsonEncode({
        'stop_reason': 'end_turn',
        'content': [
          {'type': 'text', 'text': '{"meals":[]}'},
        ],
      });
      expect(AnthropicService.extractStructuredJson(body), {
        'meals': <Object?>[],
      });
    });

    test('throws a readable error on refusal', () {
      final body = jsonEncode({
        'stop_reason': 'refusal',
        'content': <Object?>[],
      });
      expect(
        () => AnthropicService.extractStructuredJson(body),
        throwsA(isA<AnthropicException>()),
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
}
