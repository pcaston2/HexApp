import 'dart:core';

import 'hex.dart';
import 'piece.dart';

part 'boardValidator.dart';

const maxBoardSize = 10;

enum BoardMode {
  play,
  designer,
}



class Board {
  Map<Hex, List<Piece>> map = new Map<Hex, List<Piece>>();


  int _size = 3;

  bool _finished = false;

  int get size {
    return _size;
  }

  set size(int newSize) {
    if (newSize < 1 || newSize > 10) {
      throw new Exception("Cannot create a board of size $newSize");
    } else {
      _size = newSize;
    }
  }

  BoardMode _mode;

  BoardMode get mode {
    return _mode;
  }

  set mode(BoardMode currentMode) {
    if (currentMode == BoardMode.designer) {
      resetStart();
    }
    _mode = currentMode;
  }

  List<Hex> _trail = [];

  List<Hex> get trail => _trail;

  Hex get head => trail.first;

  Hex get tail => trail.isEmpty ? null : trail.last;

  Hex get previous {
    if (trail.length < 2) {
      return null;
    } else {
      return trail.elementAt(trail.length - 2);
    }
  }

  bool isStart(Hex start) {
    return hasPieceAt(start, StartPiece());
  }

  bool isEnd(Hex end) {
    return hasPieceAt(end, EndPiece());
  }

  bool isTail(Hex current) {
    if (current == null) {
      return false;
    } else {
      return current == tail;
    }
  }

  bool startAt(Hex start) {
    if (isStart(start)) {
      if (hasStarted) {
        resetStart();
      }
      _trail.add(start);
      return true;
    } else {
      resetStart();
      return false;
    }
  }

  bool get isFinished {
    return _finished;
  }

  bool get isSuccess {
    if (hasEnded && isFinished) {
      var boardValidator = new BoardValidator(this);
      return boardValidator.isSuccessful;
    }
    return false;
  }

  bool trySolve() {
    _finished = true;
    return isSuccess;
  }

  bool get hasEnded {
    if (tail == null) {
      return false;
    } else {
      return isEnd(tail);
    }
  }

  List<Hex> get adjacent {
    var validMoves = <Hex>[];
    if (hasEnded) {
      return [previous];
    }
    if (tail.runtimeType == Edge) {
      return tail.vertices.where((Vertex v) =>
      !trail.contains(v) || v == previous).toList();
    } else if (tail.runtimeType == Vertex) {
      var edges = tail.edges;
      for (Edge edge in edges) {
        if (map.containsKey(edge)) {
          if (map[edge].any((Piece p) => p.runtimeType == PathPiece)) {
            // var correspondingVertex =
            //     edge.vertices.singleWhere((Vertex v) => v != tail);
            if (!trail.contains(edge) || edge == previous) {
              validMoves.add(edge);
            }
          }
        }
      }
    }
    return validMoves;
  }

  void resetStart() {
    _trail.clear();
    _finished = false;
  }

  get hasStarted => _trail.isNotEmpty;

  bool pieceOnBoard(Hex hex) {
    num closestValue;
    for (var h in hex.faces) {
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

  Iterable<Hex> get keys => map.keys;

  Board() {
    _size = 3;
  }

  Board.sample() {
    _size = 3;

    putPiece(Hex.origin(), PathPiece());
    putPiece(Hex.position(0, 1), PathPiece());
    putPiece(Vertex(VertexType.West, 1, 1), StartPiece());
    putPiece(Vertex(VertexType.East, -1, 0), EndPiece());
    mode = BoardMode.designer;
  }

  bool putPiece(Hex hex, Piece piece) {
    //TODO: Move this to the pieces
    if (!pieceOnBoard(hex)) {
      return false;
    }
    if (piece.runtimeType == BreakRulePiece && hex.runtimeType != Hex) {
      return false;
    }
    if (piece.runtimeType == EdgeRulePiece && hex.runtimeType != Edge) {
      return false;
    }
    if ((piece.runtimeType == StartPiece || piece.runtimeType == EndPiece || piece.runtimeType == DotRulePiece) &&
        hex.runtimeType == Hex) {
      return false;
    } else if (piece.runtimeType == ErasePiece) {
      if (map.containsKey(hex)) {
        map.remove(hex);
        return true;
      } else {
        return false;
      }
    } else {
      if ((hex.runtimeType == Hex || hex.runtimeType == Vertex) &&
          piece is PathPiece) {
        bool any = false;
        for (var e in hex.edges) {
          if (putPiece(e, piece) ){
            any = true;
          }
        }
        hex.edges.forEach((Edge e) => putPiece(e, piece));
        return any;
      }
      map.putIfAbsent(hex, () => new List<Piece>.empty(growable: true));
      var pieces = map[hex];
      pieces.removeWhere((p) => p.runtimeType == piece.runtimeType);
      if (piece.runtimeType == StartPiece || piece.runtimeType == EndPiece) {
        pieces.removeWhere(
            (p) => p.runtimeType == StartPiece || p.runtimeType == EndPiece);
      }
      pieces.add(piece);
      return true;
    }
  }

  bool hasPieceAt(Hex h, Piece piece) {
    if (!map.containsKey(h)) {
      return false;
    } else {
      return map[h].any((Piece p) => p.runtimeType == piece.runtimeType);
    }
  }

  List<MapEntry<Hex, Piece>> flatten() {
    var entries = new List<MapEntry<Hex, Piece>>.empty(growable: true);
    for (Hex hex in map.keys) {
      for (Piece piece in getPiecesAt(hex)) {
        entries.add(new MapEntry<Hex, Piece>(hex, piece));
      }
    }
    return entries;
  }

  List<Piece> getPiecesAt(Hex hex) {
    if (map.containsKey(hex)) {
      return map[hex];
    } else {
      return new List<Piece>.empty();
    }
  }

  void clear() {
    map.clear();
  }

  bool moveTo(Hex hex) {
    if (adjacent.contains(hex)) {
      if (hex == previous) {
        trail.removeLast();
      } else {
        trail.add(hex);
      }
      return true;
    } else {
      return false;
    }
  }

  List<MapEntry<Hex, Piece>> getPiece(Piece p){
  return flatten().where((MapEntry<Hex, Piece> entry) => entry.value.runtimeType == p.runtimeType).toList();
}

}
