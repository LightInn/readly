import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:readly/data/services/off_service.dart';

void main() {
  final sampleProduct = {
    'status': 1,
    'product': {
      'product_name': 'Nutella',
      'brands': 'Ferrero, Nutella',
      'image_front_url': 'https://images.openfoodfacts.org/nutella.jpg',
      'quantity': '400 g',
      'serving_quantity': '15',
      'nutriments': {
        'energy-kcal_100g': 539,
        'proteins_100g': 6.3,
        'carbohydrates_100g': 57.5,
        'sugars_100g': '56,3',
        'fat_100g': 30.9,
      },
    },
  };

  group('OffProduct.fromApiJson', () {
    test('maps all nutrition fields, including comma decimals', () {
      final product = OffProduct.fromApiJson('301', sampleProduct)!;
      expect(product.name, 'Nutella');
      expect(product.brand, 'Ferrero');
      expect(product.quantity, '400 g');
      expect(product.kcalPer100g, 539);
      expect(product.sugarsPer100g, 56.3);
      expect(product.servingGrams, 15);
    });

    test('returns null when there is no product or no name', () {
      expect(OffProduct.fromApiJson('1', {'status': 0}), isNull);
      expect(
        OffProduct.fromApiJson('1', {
          'product': {'product_name': ''},
        }),
        isNull,
      );
    });
  });

  group('OpenFoodFactsService.fetchProduct', () {
    test('returns a product on 200', () async {
      final service = OpenFoodFactsService(
        client: MockClient((request) async {
          expect(request.url.path, contains('3017624010701'));
          expect(request.headers['User-Agent'], contains('Readly'));
          return http.Response(
            jsonEncode(sampleProduct),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final product = await service.fetchProduct('3017624010701');
      expect(product?.name, 'Nutella');
    });

    test('returns null on 404 and unknown products', () async {
      final notFound = OpenFoodFactsService(
        client: MockClient((_) async => http.Response('', 404)),
      );
      expect(await notFound.fetchProduct('0'), isNull);

      final unknown = OpenFoodFactsService(
        client: MockClient(
          (_) async => http.Response(jsonEncode({'status': 0}), 200),
        ),
      );
      expect(await unknown.fetchProduct('0'), isNull);
    });
  });
}
