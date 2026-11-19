import 'package:flutter/material.dart';

import '../helpers/auth_helper.dart';
import '../helpers/cart_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authHelper = AuthHelper();
  final _cartHelper = CartHelper();
  late Future<_ProfileData> _profileFuture;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<_ProfileData> _loadProfile() async {
    final email = await _authHelper.getEmail();
    final cartCount =
        email == null ? 0 : await _cartHelper.count(email);
    return _ProfileData(email: email ?? '-', cartCount: cartCount);
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });
    await widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Profil gagal dimuat.'));
        }

        final profile = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 42,
              child: Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(profile.email),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('Jumlah produk di keranjang'),
                trailing: Text(
                  '${profile.cartCount}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isLoggingOut ? null : _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileData {
  const _ProfileData({
    required this.email,
    required this.cartCount,
  });

  final String email;
  final int cartCount;
}
