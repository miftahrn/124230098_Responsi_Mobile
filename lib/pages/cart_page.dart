import 'package:flutter/material.dart';

import '../helpers/auth_helper.dart';
import '../helpers/cart_helper.dart';
import '../models/product.dart';
import 'detail_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cartHelper = CartHelper();
  final _authHelper = AuthHelper();
  String? _activeEmail;
  late Future<List<Product>> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  Future<List<Product>> _loadCart() async {
    _activeEmail = await _authHelper.getEmail();
    if (_activeEmail == null) {
      return [];
    }
    return _cartHelper.getProducts(_activeEmail!);
  }

  void _refreshCart() {
    setState(() {
      _cartFuture = _loadCart();
    });
  }

  Future<void> _removeProduct(int productId) async {
    _activeEmail ??= await _authHelper.getEmail();
    if (_activeEmail == null) return;
    await _cartHelper.remove(_activeEmail!, productId);
    if (mounted) {
      _refreshCart();
    }
  }

  Future<void> _openDetail(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetailPage(productId: product.id),
      ),
    );
    if (mounted) {
      _refreshCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: FutureBuilder<List<Product>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: FilledButton(
                onPressed: _refreshCart,
                child: const Text('Gagal memuat. Coba lagi'),
              ),
            );
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64),
                  SizedBox(height: 12),
                  Text('Keranjang masih kosong'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  onTap: () => _openDetail(product),
                  contentPadding: const EdgeInsets.all(10),
                  leading: SizedBox(
                    width: 64,
                    height: 64,
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                  title: Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('\$${product.price.toStringAsFixed(2)}'),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${product.ratingRate}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _removeProduct(product.id),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Hapus',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
