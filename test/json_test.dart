// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hex_game/hex.dart';
import 'package:hex_game/piece.dart';
import 'package:hex_game/board.dart';

void main() {
  group('Json Tests', () {
    test('Should Serialize a Piece', () {
      Piece p = DotRule();
      var json = p.toJson();
      p = Piece.fromJson(json);
      expect(p.runtimeType, DotRule);
    });
    test('Should Serialize a Board', () {
    Board b = Board.sample();
    var json = b.toJson();

    b = Board.fromJson(json);
    expect(b.runtimeType, Board);
    });
    test('Should Serialize an Edge Rule', () {
      EdgeRule edge = new EdgeRule();
      edge.count = 2;
      var json = edge.toJson();
      edge = Piece.fromJson(json);
      expect(edge.count, 2);
    });
      test('Should Serialize a Board with edge rule', () {
      Board b = Board();
      Edge edge = Edge.position(EdgeType.North, 0,0);
      EdgeRule er = EdgeRule();
      er.count = 2;
      b.putPiece(edge, er);
      var json = b.toJson();
      b = Board.fromJson(json);
      var pieces = b.getPiecesAt(edge);
      var egdeRules = pieces.whereType<EdgeRule>();
      var theEdge = egdeRules.first;
      expect(theEdge.count, 2);
    });
  });
}
