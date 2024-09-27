// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hex_game/boardTheme.dart';
import 'package:hex_game/hex.dart';
import 'package:hex_game/piece.dart';
import 'package:hex_game/board.dart';

void main() {
  group('Equality Tests', () {
    test('Rules should be equal', () {
      var rule1 = DotRule();
      var rule2 = DotRule();
      expect(rule1,rule2);
    });
    test('MapEntries should be equal', () {
      var entry1 = MapEntry<Hex, Rule>(Hex.origin(),DotRule());
      var entry2 = MapEntry<Hex, Rule>(Hex.origin(), DotRule());
      expect(entry1,entry2);
    });
    test('MapEntries should be equal when using sequences', () {
      var rule1 = SequenceRule()..colors.add(RuleColorIndex.First);
      var rule2 = SequenceRule()..colors.add(RuleColorIndex.First);
      expect(rule1, rule2);
      var hex1 = Hex.origin();
      var hex2 = Hex.origin();
      expect(hex1, hex2);
      var entry1 = MapEntry<Hex, Rule>(hex1, rule1);
      var entry2 = MapEntry<Hex, Rule>(hex2, rule2);
      expect(entry1.equals(entry2), true);
    });
  });
}
