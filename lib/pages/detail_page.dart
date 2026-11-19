import 'package:flutter/material.dart';

import '../helpers/auth_helper.dart';
import '../helpers/cart_helper.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'cart_page.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.productId});

  final int productId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _apiService = ApiService();
  final _cartHelper = CartHelper();
  final _authHelper = AuthHelper();
  late Future<Product> _productFuture;
  String? _activeEmail;
  bool _isInCart = false;
  bool _isUpdatingCart = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _loadProduct();
  }

  Future<Product> _loadProduct() async {
    final product = await _apiService.fetchProductById(widget.productId);
    _activeEmail = await _authHelper.getEmail();
    _isInCart = _activeEmail == null
        ? false
        : await _cartHelper.contains(_activeEmail!, product.id);
    return product;
  }

  Future<void> _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const CartPage(),
      ),
    );

    if (!mounted) return;
    await _refreshCartStatus();
  }

  Future<void> _refreshCartStatus() async {
    _activeEmail ??= await _authHelper.getEmail();
    if (_activeEmail == null) {
      if (mounted) setState(() => _isInCart = false);
      return;
    }

    final isInCart =
        await _cartHelper.contains(_activeEmail!, widget.productId);
    if (mounted) {
      setState(() {
        _isInCart = isInCart;
      });
    }
  }

  void _retry() {
    setState(() {
      _productFuture = _loadProduct();
    });
  }

  Future<void> _toggleCart(Product product) async {
    _activeEmail ??= await _authHelper.getEmail();
    if (_activeEmail == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi pengguna tidak tersedia.')),
        );
      }
      return;
    }

    setState(() {
      _isUpdatingCart = true;
    });

    if (_isInCart) {
      await _cartHelper.remove(_activeEmail!, product.id);
    } else {
      await _cartHelper.add(_activeEmail!, product);
    }

    if (mounted) {
      setState(() {
        _isInCart = !_isInCart;
        _isUpdatingCart = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInCart
                ? 'Produk ditambahkan ke keranjang.'
                : 'Produk dihapus dari keranjang.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(
            onPressed: _openCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Keranjang',
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: FilledButton(
                onPressed: _retry,
                child: const Text('Gagal memuat. Coba lagi'),
              ),
            );
          }

          final product = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text('${product.ratingRate} (${product.ratingCount} review)'),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isUpdatingCart
                        ? null
                        : () => _toggleCart(product),
                    icon: Icon(
                      _isInCart
                          ? Icons.remove_shopping_cart
                          : Icons.add_shopping_cart,
                    ),
                    label: Text(
                      _isInCart ? 'Remove from Cart' : 'Add to Cart',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
