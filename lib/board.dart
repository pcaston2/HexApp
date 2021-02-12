import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:path_provider/path_provider.dart';

import 'boardTheme.dart';
import 'color.dart';
import 'hex.dart';
import 'piece.dart';

import 'package:json_annotation/json_annotation.dart';

part 'boardValidator.dart';
part 'hexPieceEntry.dart';
part 'board.g.dart';

const maxBoardSize = 10;

enum BoardMode {
  play,
  designer,
}

const String BOARD_FILE_EXTENSION = "jhexboard";

@JsonSerializable(explicitToJson: true)
class Board {
  String name = "Board";

  Color board;

  Map<Hex, List<Piece>> _map = new Map<Hex, List<Piece>>();

  List<HexPieceEntry> get map {
    List<HexPieceEntry> entries = [];
    flatten().forEach((element) =>
        entries.add(HexPieceEntry.from(element.key, element.value)));
    return entries;
  }

  set map(List<HexPieceEntry> entries) {
    entries.forEach((entry) => putPiece(entry.hex, entry.piece));
  }

  BoardTheme theme;

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

  Guid _guid;

  String get guid {
    return _guid.value;
  }

  set guid(String value) {
    _guid = new Guid(value);
  }

  BoardMode _mode;

  @JsonKey(ignore: true)
  BoardMode get mode {
    return _mode;
  }

  @JsonKey(ignore: true)
  set mode(BoardMode currentMode) {
    if (currentMode == BoardMode.designer) {
      resetTrail();
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
        resetTrail();
      }
      _trail.add(start);
      return true;
    } else {
      resetTrail();
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
      return tail.vertices
          .where((Vertex v) => !trail.contains(v) || v == previous)
          .toList();
    } else if (tail.runtimeType == Vertex) {
      var edges = tail.edges;
      for (Edge edge in edges) {
        if (_map.containsKey(edge)) {
          if (_map[edge].any((Piece p) => p.runtimeType == PathPiece)) {
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

  void resetTrail() {
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

  Iterable<Hex> get keys => _map.keys;

  Board() : this.named("Board");

  Board.named(this.name) {
    _size = 3;
    _guid = Guid.newGuid;
    _mode = BoardMode.play;
  }



  Board.sample() {
    name = "Sample";

    _size = 3;

    putPiece(Hex.origin(), PathPiece());
    putPiece(Hex.position(0, 1), PathPiece());
    putPiece(Edge.position(EdgeType.North, 0, 2), StartPiece());
    putPiece(Vertex.position(VertexType.East, -1, 0), EndPiece());
    putPiece(Vertex.position(VertexType.West, 1, 0), DotRule());
    putPiece(Edge.position(EdgeType.East, 0, 0), DotRule());
    putPiece(Hex.origin(), BreakRule());
    theme = BoardTheme();
    mode = BoardMode.designer;
  }

  static Future<Board> createBoard(String boardName) async {
    Board board = new Board.named(boardName);
    board.theme = BoardTheme();
    await board.save();
    return board;
  }

  Future<void> save() async {
    var cacheDir = await getApplicationDocumentsDirectory();
    File f = File('${cacheDir.path}/board_$guid.$BOARD_FILE_EXTENSION');
    f.writeAsString(json.encode(toJson()));
  }

  bool putPiece(Hex hex, Piece piece) {
    //TODO: Move this to the pieces
    if (!pieceOnBoard(hex)) {
      return false;
    }
    if (piece.runtimeType == BreakRule && hex.runtimeType != Hex) {
      return false;
    }
    if (piece.runtimeType == EdgeRule && hex.runtimeType != Edge) {
      return false;
    }
    if ((piece.runtimeType == StartPiece ||
            piece.runtimeType == EndPiece ||
            piece.runtimeType == DotRule) &&
        hex.runtimeType == Hex) {
      return false;
    } else if (piece.runtimeType == ErasePiece) {
      if (_map.containsKey(hex)) {
        List<Piece> pieces = _map[hex];
        if (pieces.isNotEmpty) {
          pieces.sort((a, b) => b.order.compareTo(a.order));
          var first = pieces.first;
          pieces.remove(first);
          return true;
        }
        _map.remove(hex);
        return true;
      } else {
        return false;
      }
    } else {
      if ((hex.runtimeType == Hex || hex.runtimeType == Vertex) &&
          piece is PathPiece) {
        bool any = false;
        for (var e in hex.edges) {
          if (putPiece(e, piece)) {
            any = true;
          }
        }
        hex.edges.forEach((Edge e) => putPiece(e, piece));
        return any;
      }
      _map.putIfAbsent(hex, () => new List<Piece>.empty(growable: true));
      var pieces = _map[hex];
      if (piece.runtimeType == EdgeRule) {
        if (pieces.any((Piece p) => p.runtimeType == EdgeRule)) {
          EdgeRule existing =
              pieces.singleWhere((Piece p) => p.runtimeType == EdgeRule);
          existing.count = existing.count == 1 ? 2 : 1;
        } else {
          pieces.add(piece);
        }
        return true;
      } else {
        pieces.removeWhere((p) => p.runtimeType == piece.runtimeType);
      }
      if (piece.runtimeType == StartPiece || piece.runtimeType == EndPiece) {
        pieces.removeWhere(
            (p) => p.runtimeType == StartPiece || p.runtimeType == EndPiece);
      }
      pieces.add(piece);
      return true;
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

  List<MapEntry<Hex, T>> getPiece<T>() {
    return flatten()
        .where((MapEntry<Hex, Piece> entry) =>
            entry.value.runtimeType == T).map((entry) => MapEntry<Hex, T>(entry.key, entry.value as T))
        .toList();
  }

  factory Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);

  Map<String, dynamic> toJson() => _$BoardToJson(this);
}
