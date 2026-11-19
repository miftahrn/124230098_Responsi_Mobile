import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://fakestoreapi.com/products';

  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    final response = await _get(_baseUrl);
    final decoded = _decodeBody(response.body);
    if (decoded is! List) {
      throw const ApiException('Format daftar produk tidak valid.');
    }

    final products = <Product>[];
    for (final item in decoded) {
      if (item is Map) {
        try {
          products.add(Product.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          throw const ApiException('Format salah pada salah satu data produk.');
        }
      }
    }
    return products;
  }

  Future<Product> fetchProductById(int id) async {
    final response = await _get('$_baseUrl/$id');
    final decoded = _decodeBody(response.body);
    if (decoded is! Map) {
      throw const ApiException('Format detail produk tidak valid.');
    }

    try {
      return Product.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      throw const ApiException('Format data detail produk tidak valid.');
    }
  }

  dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } on FormatException catch (error) {
      throw ApiException('Format respons server tidak valid: $error');
    }
  }

  Future<http.Response> _get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'Gagal mengambil data produk (HTTP ${response.statusCode}).',
        );
      }

      return response;
    } on http.ClientException catch (error) {
      throw ApiException('Tidak dapat terhubung ke server: $error');
    }
  }
}
