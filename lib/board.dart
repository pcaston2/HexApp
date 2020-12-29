import 'dart:collection';


import 'hex.dart';
import 'piece.dart';

const maxBoardSize = 10;

class Board {
  var _map = new HashMap<Hex, List<Piece>>();

  int _size = 3;

  get size => _size;

  bool pieceOnBoard(Hex hex) {
    num closestValue = null;
    for(var h in hex.faces) {
      var currentValue = h.distanceFromOrigin();
      if (closestValue == null) {
        closestValue = currentValue;
      } else {
        if (currentValue < closestValue) {
          closestValue = currentValue;
        }
      }
    }
    //num min = hex.faces.reduce((Hex h) => h.distanceFromOrigin());
    return closestValue <= _size - 1;
  }



  Iterable<Hex> get keys => _map.keys;

  Board.sample() {
    _size = 2;

    putPiece(Hex.origin(), EdgePiece());
    putPiece(Hex.position(0, 1), EdgePiece());
    putPiece(Vertex(VertexType.West, 1, 1), StartPiece());
    putPiece(Vertex(VertexType.East, -1, 0), EndPiece());
  }

  void putPiece(Hex hex, Piece piece) {
    if (piece.runtimeType == ClearPiece) {
      _map.clear();
      return;
    } else if ((piece.runtimeType == StartPiece || piece.runtimeType == EndPiece) && hex.runtimeType != Vertex) {
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