import 'dart:collection';


import 'hex.dart';
import 'piece.dart';

class Board {
  var _map = new HashMap<Hex, List<Piece>>();
  Iterable<Hex> get keys => _map.keys;
  Board.sample() {
    putPiece(new Edge(EdgeType.West, 2,2), new EdgePiece());
    putPiece(new Edge(EdgeType.East, 1,3), new EdgePiece());
  }

  void putPiece(Hex hex, Piece piece) {
        _map.putIfAbsent(hex, () => new List<Piece>.empty(growable: true));
        var pieces = _map[hex];
        if (hex.runtimeType == Hex && piece is EdgePiece) {
          hex.edges.forEach((Edge e) => putPiece(e, piece));
        }
        pieces.removeWhere((p) => p.runtimeType == piece.runtimeType);
        pieces.add(piece);
  }

  List<Piece> getPiecesAt(Hex hex) {
    if (_map.containsKey(hex)) {
      return _map[hex];
    } else {
      return new List<Piece>.empty();
    }
  }

}