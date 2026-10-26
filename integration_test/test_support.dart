import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const testEmailA = String.fromEnvironment('ANDROID_TEST_EMAIL_A');
const testEmailB = String.fromEnvironment('ANDROID_TEST_EMAIL_B');
const testPassword = String.fromEnvironment('ANDROID_TEST_PASSWORD');
const testNameA = String.fromEnvironment('ANDROID_TEST_NAME_A');
const testNameB = String.fromEnvironment('ANDROID_TEST_NAME_B');
const updatedName = String.fromEnvironment('ANDROID_TEST_UPDATED_NAME');

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 45),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(finder, findsWidgets);
  await tester.pumpAndSettle();
}

Future<void> fillLogin(
  WidgetTester tester,
  String email,
  String password,
) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), password);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
}

Future<void> register(WidgetTester tester, String name, String email) async {
  await tester.tap(find.widgetWithText(TextButton, 'Kayıt Ol'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), name);
  await tester.enterText(find.byType(TextField).at(1), email);
  await tester.enterText(find.byType(TextField).at(2), testPassword);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Kayıt Ol'));
  await tester.tap(find.widgetWithText(ElevatedButton, 'Kayıt Ol'));
  await waitFor(tester, find.byType(NavigationBar));
}

Future<void> openProfile(WidgetTester tester) async {
  await tester.tap(find.byType(NavigationDestination).at(3));
  await tester.pumpAndSettle();
}
