part of 'board.dart';

enum BoardValidationErrorType {
  didNotStartFromABeginning,
  didNotFinishAtAnEnd,
  dotNotCovered,
  tooManyDots,
  edgeNotTraversed,
  tooManyEdges,
  cornerNotTraversed,
  tooManyCorners,
  colorOrder,
  differentColorOverlap,
  noColorAtSequence,
  colorNotInSequence,
  colorNotSatisfied,
}

class BoardValidator {
  Board _board;

  BoardValidator(this._board) {
    errors = [];
    var trailErrors = validateTrail();
    errors.addAll(trailErrors);
    if (trailErrors.isNotEmpty) {
      return;
    } else {
      errors.addAll(validateColorsAndSequence());
      errors.addAll(validateDots());
      errors.addAll(validateEdges());
      errors.addAll(validateCorners());
    }
  }

  late List<BoardValidationError> errors;

  bool get isSuccessful => errors.isEmpty;

  List<BoardValidationError> validateTrail() {
    List<BoardValidationError> trailErrors = [];
    if (!_board.hasPieceAt(_board.head, StartPiece())) {
      trailErrors.add(BoardValidationError(_board.head, null,
          BoardValidationErrorType.didNotStartFromABeginning));
    }
    if (!_board.hasPieceAt(_board.tail, EndPiece())) {
      trailErrors.add(BoardValidationError(
          _board.tail, null, BoardValidationErrorType.didNotFinishAtAnEnd));
    }
    //TODO: Check that the trail is continuous, refactor adjacent to help
    return trailErrors;
  }


  List<BoardValidationError> validateColorsAndSequence() {
    List<BoardValidationError> colorErrors = [];
    List<RuleColorIndex> previousColors = [];
    void addColor(Hex trail, ColoredRule rule) {
      if (previousColors.isEmpty) {
        previousColors.add(rule.color);
      } else {
        if (previousColors.last != rule.color) {
          if (previousColors.contains(rule.color)) {
            colorErrors.add(new BoardValidationError(
                trail, rule, BoardValidationErrorType.colorOrder));
          } else {
            previousColors.add(rule.color);
          }
        }
      }
    }
    var copyOfSequenceRules = _board.getPiece<SequenceRule>().map((e) => new MapEntry<Hex, SequenceRule>(e.key, e.value.clone() as SequenceRule)).toList();
    List<Hex> previousFaces = [];
    for (var trail in _board.trail) {
      var dot = _board.getPiece<DotRule>().singleWhereOrNull((d) => d.key == trail);
      if (dot != null) {
        addColor(trail, dot.value);
      }
      if (trail.runtimeType == Vertex) {
      } else if (trail.runtimeType == Edge) {
        var edgeRules = _board.getPiece<EdgeRule>().where((e) => e.key == trail || ((e.key as Edge).parallelEdge == trail));
        var dotRules = _board.getPiece<DotRule>().where((e) => e.key == trail);
        var coloredRules = List<MapEntry<Hex, ColoredRule>>.from(dotRules)..addAll(edgeRules);
        if (coloredRules.isNotEmpty) {
          if (coloredRules.length == 1) {
            addColor(trail, coloredRules.single.value);
          } else {
            if (coloredRules.any((r) => r.value.color != coloredRules.first.value.color)) {
              for (var rule in coloredRules) {
                colorErrors.add(BoardValidationError(rule.key, rule.value, BoardValidationErrorType.differentColorOverlap));
              }
            }
          }
        }
      }
      var currentFaces = trail.faces;
      var sequenceRules = copyOfSequenceRules.where((e) => currentFaces.contains(e.key));
      if (sequenceRules.isNotEmpty) {
        //add if empty, or error
        if (previousColors.isEmpty) {
          if (sequenceRules.every((r) => r.value.colors.every((c) => c ==
              sequenceRules.first.value.colors.first))) {
            previousColors.add(sequenceRules.first.value.colors.first);
          } else {
            for (var rule in sequenceRules) {
              if (!previousFaces.contains(rule.key)) {
                colorErrors.add(new BoardValidationError(rule.key, rule.value,
                    BoardValidationErrorType.differentColorOverlap));
              }
            }
          }
        }
        if (!previousColors.isEmpty) {
          for (var sequenceRule in sequenceRules) {
            if (!previousFaces.contains(sequenceRule.key)) {
              if (!sequenceRule.value.colors.remove(previousColors.last)) {
                colorErrors.add(new BoardValidationColorError(
                    sequenceRule.key, sequenceRule.value,
                    BoardValidationErrorType.colorNotInSequence,
                    previousColors.last));
              }
            }
          }
        }
      }
      previousFaces = currentFaces;
    }
    for (var sequenceRule in copyOfSequenceRules) {
      if (sequenceRule.value.colors.isNotEmpty) {
        for (var colorIndex in sequenceRule.value.colors) {
          colorErrors.add(new BoardValidationColorError(sequenceRule.key, sequenceRule.value, BoardValidationErrorType.colorNotSatisfied,colorIndex));
        }
      }
    }
    return colorErrors;
  }

  List<BoardValidationError> validateEdges() {
    List<BoardValidationError> edgeErrors = [];
    var edgePieces = _board.getPiece<EdgeRule>();
    for (var entry in edgePieces) {
      Edge edge = entry.key as Edge;
      EdgeRule edgePiece = entry.value;
      List<Edge> edges = [];
      edges.add(edge);
      edges.add(edge.parallelEdge);
      int expected = edgePiece.count;
      int traversed =
          edges.where((Edge e) => _board.trail.contains(e)).toList().length;
      if (traversed == expected) {
      } else {
        edges.forEach((Edge e) => edgeErrors.add(BoardValidationError(
            e,
            edgePiece,
            traversed < expected
                ? BoardValidationErrorType.edgeNotTraversed
                  : BoardValidationErrorType.tooManyEdges)));
      }
    }
    return edgeErrors;
  }

  List<BoardValidationError> validateCorners() {
    List<BoardValidationError> cornerErrors = [];
    var cornerRules = _board.getPiece<CornerRule>();
    for (var entry in cornerRules) {
      Edge edge = entry.key as Edge;
      CornerRule cornerRule = entry.value;
      List<Vertex> corners = new List<Vertex>.from(edge.vertices);
      int expected = cornerRule.count;
      int traversed = corners.where((Vertex v) => _board.trail.contains(v)).toList().length;
      if (traversed != expected) {
        cornerErrors.add(BoardValidationError(
          edge,cornerRule, traversed < expected ?
            BoardValidationErrorType.cornerNotTraversed :
            BoardValidationErrorType.tooManyCorners
        ));
      }
    }
    return cornerErrors;
  }

  List<BoardValidationError> validateDots() {
    List<BoardValidationError> dotErrors = [];
    List<MapEntry<Hex, DotRule>> allDotPieces = _board.getPiece<DotRule>();
    Map<RuleColorIndex, List<MapEntry<Hex, DotRule>>> groupedDotRules = groupBy(
        allDotPieces, (MapEntry<Hex, DotRule> entries) => entries.value.color);
    for (var dotPieces in groupedDotRules.values) {
      if (dotPieces.isNotEmpty) {
        List<MapEntry<Hex, DotRule>> covered = [];
        List<MapEntry<Hex, DotRule>> uncovered = [];
        for (MapEntry<Hex, DotRule> entry in dotPieces) {
          if (_board.trail.contains(entry.key)) {
            covered.add(entry);
          } else {
            uncovered.add(entry);
          }
        }

        int coveredDotCount = covered.length;
        if (coveredDotCount > 1) {
          dotErrors.addAll(covered.map<BoardValidationError>(
              (MapEntry<Hex, DotRule> entry) => BoardValidationError(entry.key,
                  entry.value, BoardValidationErrorType.tooManyDots)));
        } else if (coveredDotCount < 1) {
          dotErrors.addAll(uncovered.map<BoardValidationError>(
              (MapEntry<Hex, DotRule> entry) => BoardValidationError(entry.key,
                  entry.value, BoardValidationErrorType.dotNotCovered)));
        }
      }
    }

    return dotErrors;
  }

  @override
  String toString() {
    var msg = isSuccessful ? 'Success' : 'Error';
    for (var validationError in errors) {
      msg += '\r\n';
      msg += validationError.toString();
    }
    return msg;
  }
}

class BoardValidationError {
  Hex? hex;
  Piece? piece;
  BoardValidationErrorType type;
  BoardValidationError(this.hex, this.piece, this.type);

  @override
  String toString() {
    String msg = "";
    msg += '${type} at ${hex}';
    if (piece != null) {
      msg += ' for ${piece}';
    }
    return msg;
  }
}

class BoardValidationColorError extends BoardValidationError {
  late RuleColorIndex color;
  BoardValidationColorError(Hex hex, Piece piece, BoardValidationErrorType error, this.color) : super(hex, piece, error);

  @override
  String toString() {
    return "${super.toString()} with ${color} color";
  }
}