import 'dart:convert';

import 'package:http/http.dart' as http;

/// A product looked up on Open Food Facts.
class OffProduct {
  const OffProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.quantity,
    this.kcalPer100g,
    this.proteinsPer100g,
    this.carbsPer100g,
    this.sugarsPer100g,
    this.fatsPer100g,
    this.servingGrams,
  });

  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;

  /// Package size as printed, e.g. "500 g".
  final String? quantity;
  final double? kcalPer100g;
  final double? proteinsPer100g;
  final double? carbsPer100g;
  final double? sugarsPer100g;
  final double? fatsPer100g;
  final double? servingGrams;

  /// Parses an Open Food Facts v2 product payload. Returns null when the
  /// product is unknown or has no usable name.
  static OffProduct? fromApiJson(String barcode, Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) return null;
    final name = (product['product_name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;

    final nutriments =
        (product['nutriments'] as Map<String, dynamic>?) ?? const {};
    return OffProduct(
      barcode: barcode,
      name: name,
      brand: (product['brands'] as String?)?.split(',').first.trim(),
      imageUrl: product['image_front_url'] as String?,
      quantity: product['quantity'] as String?,
      kcalPer100g: _asDouble(nutriments['energy-kcal_100g']),
      proteinsPer100g: _asDouble(nutriments['proteins_100g']),
      carbsPer100g: _asDouble(nutriments['carbohydrates_100g']),
      sugarsPer100g: _asDouble(nutriments['sugars_100g']),
      fatsPer100g: _asDouble(nutriments['fat_100g']),
      servingGrams: _asDouble(product['serving_quantity']),
    );
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }
}

/// Minimal Open Food Facts v2 client.
class OpenFoodFactsService {
  OpenFoodFactsService({http.Client? client})
    : _client = client ?? http.Client();

  static const _fields =
      'product_name,brands,image_front_url,quantity,'
      'nutriments,serving_quantity';

  final http.Client _client;

  /// Looks up a product by barcode. Returns null when not found.
  Future<OffProduct?> fetchProduct(String barcode) async {
    final uri = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json?fields=$_fields',
    );
    final response = await _client
        .get(
          uri,
          // OFF asks API users to identify themselves.
          headers: {'User-Agent': 'Readly/3.0 (personal kcal tracker)'},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Open Food Facts error ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['status'] == 0) return null;
    return OffProduct.fromApiJson(barcode, json);
  }
}
