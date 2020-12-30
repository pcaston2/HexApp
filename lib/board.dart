import 'dart:collection';
import 'dart:core';

import 'hex.dart';
import 'piece.dart';

const maxBoardSize = 10;

enum BoardMode {
  play,
  designer,
}

class Board {
  var _map = new HashMap<Hex, List<Piece>>();

  int _size = 3;

  get size => _size;

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

  ListQueue<Vertex> _trail = ListQueue<Vertex>();

  ListQueue<Vertex> get trail => _trail;

  Vertex get head => trail.first;

  Vertex get tail => trail.last;

  Vertex get previous {
    if (trail.length < 2) {
      return null;
    } else {
      return trail.elementAt(trail.length -2);
    }
  }

  bool startAt(Vertex vertex) {
    if (hasPieceAt(vertex, StartPiece())) {
      bool startFromSameSpot = false;
      if (hasStarted) {
        if (head == vertex) {
          startFromSameSpot = true;
        }
        resetStart();
      }
      if (!startFromSameSpot) {
        _trail.addFirst(vertex);
      }
      return true;
    } else {
      resetStart();
      return false;
    }
  }

  bool get hasEnded {
    if (tail == null) {
      return false;
    } else if (_map.containsKey(tail)) {
      return _map[tail].any((Piece p) => p.runtimeType == EndPiece);
    } else {
      return false;
    }
  }

  List<Vertex> get adjacent {
    var validVertices = <Vertex>[];
    if (hasEnded) {
      return [previous];
    }
    var edges = tail.edges;
    for (Edge edge in edges) {
      if (_map.containsKey(edge)) {
        if (_map[edge].any((Piece p) => p.runtimeType == EdgePiece)) {
          var correspondingVertex = edge.vertices.singleWhere((Vertex v) => v != tail);
          if (!trail.contains(correspondingVertex) || correspondingVertex == previous) {
            validVertices.add(correspondingVertex);
          }
        }
      }
    }
    return validVertices;
  }

  void resetStart() {
    _trail.clear();
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

  Iterable<Hex> get keys => _map.keys;

  Board.sample() {
    _size = 2;

    putPiece(Hex.origin(), EdgePiece());
    putPiece(Hex.position(0, 1), EdgePiece());
    putPiece(Vertex(VertexType.West, 1, 1), StartPiece());
    putPiece(Vertex(VertexType.East, -1, 0), EndPiece());
    mode = BoardMode.designer;
  }

  void putPiece(Hex hex, Piece piece) {
    if (!pieceOnBoard(hex)) {
      return;
    }
    if ((piece.runtimeType == StartPiece || piece.runtimeType == EndPiece) &&
        hex.runtimeType != Vertex) {
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
      if (piece.runtimeType == StartPiece || piece.runtimeType == EndPiece) {
        pieces.removeWhere(
            (p) => p.runtimeType == StartPiece || p.runtimeType == EndPiece);
      }
      pieces.add(piece);
    }
  }

  bool hasPieceAt(Hex h, Piece piece) {
    if (!_map.containsKey(h)) {
      return false;
    } else {
      return _map[h].any((Piece p) => p.runtimeType == piece.runtimeType);
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

  void clear() {
    _map.clear();
  }

  bool moveTo(Vertex vertex) {
    if (adjacent.contains(vertex)) {
      if (vertex == previous){
        trail.removeLast();
      } else {
        trail.add(vertex);
      }
      return true;
    } else {
      return false;
    }
  }
}
