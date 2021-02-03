part of 'board.dart';

enum BoardValidationErrorType {
  didNotStartFromABeginning,
  didNotFinishAtAnEnd,
  dotNotCovered,
  tooManyDots,
  edgeNotTraversed,
  tooManyEdges,
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
      errors.addAll(validateDots());
      errors.addAll(validateEdges());
    }
    print(errors);
  }

  List<BoardValidationError> errors;

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

  List<BoardValidationError> validateEdges() {
    List<BoardValidationError> edgeErrors = [];
    var edgePieces = _board.getPiece<EdgeRule>();
    for (var entry in edgePieces) {
      Edge edge = entry.key;
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
        // for (Hex h in _board.trail) {
        //   if (_board.hasPieceAt(h, DotRule())) {
        //     coveredDotCount++;
        //   }
        // }

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

        // dotPieces.forEach((MapEntry<Hex, Piece> e) {
        //   if (coveredDotCount > 1) {
        //     if (_board.trail.contains(e.key)) {
        //       dotErrors.add(BoardValidationError(
        //           e.key, e.value, BoardValidationErrorType.tooManyDots));
        //     }
        //   } else {
        //     if (!_board.trail.contains(e.key)) {
        //       dotErrors.add(BoardValidationError(
        //           e.key, e.value, BoardValidationErrorType.dotNotCovered));
        //     }
        //   }
        // });
        // }
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
  Hex _hex;
  Piece _piece;
  BoardValidationErrorType _type;
  BoardValidationError(this._hex, this._piece, this._type);

  @override
  String toString() {
    String msg = "";
    msg += '${_type} at ${_hex}';
    if (_piece != null) {
      msg += ' for ${_piece}';
    }
    return msg;
  }
}
