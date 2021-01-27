// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hex_game/hex.dart';
import 'package:hex_game/color.dart';

void main() {
  group('Json Tests', () {
    test('Should Rotate a Point', () {
      Point expected = Point(0.0, 1.0);
      Point actual = Point(1.0,0.0).rotate(90);
    });
    test('Should lighten a color', () {
      Color a = Color();
      print(a.hexCode);
      print(a.darken().hexCode);
    });
  });
}
