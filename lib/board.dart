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
    if (piece.runtimeType == ClearPiece) {
      _map.clear();
      return;
    } else if (piece.runtimeType == StartPiece && hex.runtimeType == Hex) {
      return;
    } else if (piece.runtimeType == ErasePiece) {
      if (_map.containsKey(hex)) {
        _map.remove(hex);
        return;
      }
    } else {
      if ((hex.runtimeType == Hex || hex.runtimeType == Vertex) &&
          piece is EdgePiece) {
        hex.edges.forEach((Edge e) => putPiece(e, piece));
        return;
      }
      _map.putIfAbsent(hex, () => new List<Piece>.empty(growable: true));
      var pieces = _map[hex];
      pieces.removeWhere((p) => p.runtimeType == piece.runtimeType);
      pieces.add(piece);
    }
  }


  List<MapEntry<Hex, Piece>> flatten() {
    var entries = new List<MapEntry<Hex, Piece>>.empty(growable: true);
    for (Hex hex in _map.keys) {
      for (Piece piece in getPiecesAt(hex)) {
        entries.add(new MapEntry<Hex, Piece>(hex, piece));
      }
    }
    return entries;
  }

  List<Piece> getPiecesAt(Hex hex) {
    if (_map.containsKey(hex)) {
      return _map[hex];
    } else {
      return new List<Piece>.empty();
    }
  }

}