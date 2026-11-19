import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:responsi/helpers/auth_helper.dart';
import 'package:responsi/pages/login_page.dart';

void main() {
  testWidgets('Login validates required fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(onLoginSuccess: () {}),
      ),
    );

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('Login validates email and password rules',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(onLoginSuccess: () {}),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'email-tidak-valid',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      '123',
    );
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(find.text('Password minimal 6 karakter'), findsOneWidget);
  });

  test('Local authentication stores separate password hashes', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthHelper();

    expect(
      await auth.authenticate(' userA@gmail.com ', 'shopedia123'),
      AuthResult.success,
    );
    expect(
      await auth.authenticate('userA@gmail.com', '123456'),
      AuthResult.wrongPassword,
    );
    expect(
      await auth.authenticate('USERA@gmail.com', 'shopedia123'),
      AuthResult.success,
    );
    expect(
      await auth.authenticate('userB@gmail.com', '123456'),
      AuthResult.success,
    );
  });
}
