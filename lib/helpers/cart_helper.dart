import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';

class CartHelper {
  static const boxName = 'cart_box';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(boxName);
  }

  Future<Box<dynamic>> get _box async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }

    return Hive.openBox<dynamic>(boxName);
  }

  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  Future<List<Product>> getProducts(String email) async {
    final box = await _box;
    final normalizedEmail = normalizeEmail(email);
    final storedProducts = box.get(normalizedEmail);

    if (storedProducts is! List) {
      return [];
    }

    final products = <Product>[];
    for (final value in storedProducts) {
      if (value is Map) {
        try {
          products.add(
            Product.fromJson(Map<String, dynamic>.from(value)),
          );
        } catch (_) {
          // Lewati data Cart lama atau rusak agar aplikasi tetap berjalan.
        }
      }
    }
    return products;
  }

  Future<bool> contains(String email, int productId) async {
    final products = await getProducts(email);
    return products.any((product) => product.id == productId);
  }

  Future<void> add(String email, Product product) async {
    final box = await _box;
    final normalizedEmail = normalizeEmail(email);
    final products = await getProducts(normalizedEmail);
    final updatedProducts = products
        .where((item) => item.id != product.id)
        .toList()
      ..add(product);

    await box.put(
      normalizedEmail,
      updatedProducts.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> remove(String email, int productId) async {
    final box = await _box;
    final normalizedEmail = normalizeEmail(email);
    final products = await getProducts(normalizedEmail);
    final updatedProducts =
        products.where((item) => item.id != productId).toList();

    await box.put(
      normalizedEmail,
      updatedProducts.map((item) => item.toJson()).toList(),
    );
  }

  Future<int> count(String email) async {
    final products = await getProducts(email);
    return products.length;
  }
}
