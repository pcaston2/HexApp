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
    var edgePieces = _board.getPiece(EdgeRulePiece());
    for(var entry in edgePieces) {
      Edge edge = entry.key;
      EdgeRulePiece edgePiece = entry.value;
      List<Edge> edges = [];
      edges.add(edge);
      edges.add(edge.parallelEdge);
      int expected = edgePiece.count;
      int traversed = edges.where((Edge e) => _board.trail.contains(e)).toList().length;
      if (traversed == expected) {

      } else {
        edges.forEach((Edge e) => edgeErrors.add(BoardValidationError(
            e, edgePiece,
            traversed < expected ?
              BoardValidationErrorType.edgeNotTraversed :
              BoardValidationErrorType.tooManyEdges
        )));
      }
    }
    return edgeErrors;
  }

  List<BoardValidationError> validateDots() {
    List<BoardValidationError> dotErrors = [];
    var dotPieces = _board.getPiece(DotRulePiece());
    if (dotPieces.isNotEmpty) {
      int coveredDotCount = 0;
      for (Hex h in _board.trail) {
        if (_board.hasPieceAt(h, DotRulePiece())) {
          coveredDotCount++;
        }
      }
      if (coveredDotCount != 1) {
        dotPieces.forEach((MapEntry<Hex, Piece> e) {
          if (coveredDotCount > 1) {
            if (_board.trail.contains(e.key)) {
              dotErrors.add(BoardValidationError(
                  e.key, e.value, BoardValidationErrorType.tooManyDots));
            }
          } else {
            if (!_board.trail.contains(e.key)) {
              dotErrors.add(BoardValidationError(
                  e.key, e.value, BoardValidationErrorType.dotNotCovered));
            }
          }
        });
      }
    }
    return dotErrors;
  }

  @override
  String toString() {
    var msg = isSuccessful ? 'Success' : 'Error';
    for (var validationError in errors) {
      msg += '\r\n';
      msg += '${validationError._type} at ${validationError._hex}';
      if (validationError._piece != null) {
        msg += ' for ${validationError._piece}';
      }
    }
    return msg;
  }
}



class BoardValidationError {
  Hex _hex;
  Piece _piece;
  BoardValidationErrorType _type;
  BoardValidationError(this._hex, this._piece, this._type);
}