import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthResult {
  success,
  wrongPassword,
}

class AuthHelper {
  static const _isLoggedInKey = 'is_logged_in';
  static const _emailKey = 'user_email';
  static const _accountsKey = 'shopedia_accounts';

  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Map<String, dynamic> _readAccounts(String? accountsJson) {
    if (accountsJson == null || accountsJson.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(accountsJson);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{};
  }

  Future<AuthResult> authenticate(String email, String password) async {
    final preferences = await SharedPreferences.getInstance();
    final normalizedEmail = normalizeEmail(email);
    final accounts =
        _readAccounts(preferences.getString(_accountsKey));
    final passwordHash = _hashPassword(password);

    if (accounts.containsKey(normalizedEmail)) {
      if (accounts[normalizedEmail] != passwordHash) {
        return AuthResult.wrongPassword;
      }
    } else {
      accounts[normalizedEmail] = passwordHash;
      await preferences.setString(_accountsKey, jsonEncode(accounts));
    }

    await preferences.setBool(_isLoggedInKey, true);
    await preferences.setString(_emailKey, normalizedEmail);
    return AuthResult.success;
  }

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isLoggedInKey) ?? false;
  }

  Future<String?> getEmail() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(_emailKey);
    if (email == null || email.trim().isEmpty) {
      return null;
    }
    return normalizeEmail(email);
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_isLoggedInKey);
    await preferences.remove(_emailKey);
  }
}
