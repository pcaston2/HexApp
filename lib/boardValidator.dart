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
  colorNotInOrder,
  colorNotSatisfied,
  noColorsRemaining,
}

extension RulesEntryComparison on MapEntry<Hex, Rule> {
  bool equals(MapEntry<Hex, Rule> other) {
    return other.key == key && other.value == value;
  }
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
      var trail = getColorTrail();
      errors.addAll(trail.errors);
      errors.addAll(validateDots());
      errors.addAll(validateEdges());
      errors.addAll(validateCorners());
    }
    if (errors.isNotEmpty) {
      var index = 0;
      print("Errors:");
      for (var e in errors) {
        index++;
        print("${index}. ${e.toString()}");
      }
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

  ColorTrail getColorTrail(
      [List<Hex>? trail,
      List<MapEntry<Hex, Rule>>? rules,
      List<RuleColorIndex>? colorOrder,
      List<Hex>? previousFaces]) { //Initialize properties
    if (trail == null) {
      return getColorTrail(_board.trail, rules);
    }
    if (rules == null) {
      var allRules = _board
          .flatten()
          .where((MapEntry<Hex, Piece> entry) => entry.value is Rule)
          .map((entry) =>
              MapEntry<Hex, Rule>(entry.key, entry.value.clone() as Rule))
          .toList();
      return getColorTrail(trail, allRules);
    }
    if (colorOrder == null) {
      return getColorTrail(trail, rules, []);
    }
    if (previousFaces == null) {
      return getColorTrail(trail, rules, colorOrder, []);
    }

    if (trail.isNotEmpty) { //Get relevant data for this trail piece
      var current = trail.first;
      var faces = current.faces;
      var localEdgeRules = rules
          .where((e) =>
              e.value is EdgeRule &&
              (e.key == current || ((e.key as Edge).parallelEdge == current)))
          .toList();
      var localDotRules =
          rules.where((e) => e.value is DotRule && e.key == current).toList();
      var localCornerRules = rules
          .where((e) => e.value is CornerRule && e.key.edges.contains(current))
          .toList();
      var newFaces = faces.where((f) => !previousFaces.contains(f));
      var localSequenceRule = rules.singleWhereOrNull(
          (e) => e.value is SequenceRule && newFaces.contains(e.key));
      //Handles sequences first
      if (localSequenceRule != null) {
        var sequenceMap = MapEntry<Hex, SequenceRule>(localSequenceRule.key, localSequenceRule.value as SequenceRule);
        if (sequenceMap.value.colors.isEmpty) {
          return getColorTrail(trail, rules, colorOrder, faces)
            ..trail.add(ColorTrailItem(
                ColorTrailReason.NoColorsInSequence,
                hex: current,
                rule: localSequenceRule.value,
                color: colorOrder.lastOrNull,
                errors: [
                  BoardValidationError(
                      localSequenceRule.key,
                      localSequenceRule.value,
                      BoardValidationErrorType.noColorsRemaining)
                ]));
        } else {
          if (colorOrder.isEmpty) {
            ColorTrail? best;
            for (var c in sequenceMap.value.colors) {
              var newRules = rules
                  .map((e) => MapEntry<Hex, Rule>(e.key, e.value.clone()))
                  .toList();
              var currentSequence = newRules
                  .singleWhere((e) => e.equals(sequenceMap))
                  .value as SequenceRule;
              currentSequence.colors.remove(c);
              var newColorOrder = [c];
              var currentTrail =
                  getColorTrail(trail, newRules, newColorOrder, faces);
              currentTrail.trail.add(ColorTrailItem(
                  ColorTrailReason.SequenceColorSelected,
                  hex: current, rule: currentSequence, color: c));
              best = best ?? currentTrail;
              best = (best.errors.length < currentTrail.errors.length
                  ? best
                  : currentTrail);
              if (best.valid) {
                return best;
              }
            }
            return best!;
          } else {
            if (sequenceMap.value.colors.contains(colorOrder.last)) {
              var newRules = rules
                  .map((e) => MapEntry<Hex, Rule>(e.key, e.value.clone()))
                  .toList();
              var currentSequence = newRules
                  .singleWhere((e) => e.equals(sequenceMap))
                  .value as SequenceRule;
              currentSequence.colors.remove(colorOrder.last);
              return getColorTrail(trail, newRules, colorOrder, faces)
                ..trail.add(ColorTrailItem(
                    ColorTrailReason.SequenceColorFound,
                    hex: current,
                    rule: currentSequence,
                    color: colorOrder.last));
            } else {
              return getColorTrail(trail, rules, colorOrder, faces)
                ..trail.add(ColorTrailItem(
                    ColorTrailReason.ColorNotInSequence,
                    hex: current,
                    rule: localSequenceRule.value,
                    color: colorOrder.last,
                    errors: [
                      BoardValidationError(
                          localSequenceRule.key,
                          localSequenceRule.value,
                          BoardValidationErrorType.colorNotInSequence)
                    ]));
            }
          }
        }
      }

      var localColoredRules = List<MapEntry<Hex, Rule>>.from(localEdgeRules)
        ..addAll(localDotRules)
        ..addAll(localCornerRules)
        ..cast<MapEntry<Hex, ColoredRule>>();
      if (localColoredRules.isEmpty) { //Skip trail if no rules
        return getColorTrail(trail.skip(1).toList(), rules, colorOrder, faces)
          ..trail.add(ColorTrailItem(ColorTrailReason.Skip, hex: current));
      } else { //If color rules has elements, handle them

        ColorTrail? best;
        for (var r in localColoredRules) {
          var newErrors = <BoardValidationError>[];
          var newRules = rules
              .map((e) => MapEntry<Hex, Rule>(e.key, e.value.clone()))
              .toList();
          newRules.removeWhere((e) => e.equals(r));
          var newColor = (r.value as ColoredRule).color;
          var newColorOrder = List<RuleColorIndex>.from(colorOrder);
          if (newColorOrder.contains(newColor)) {
            if (newColorOrder.last != newColor) {
              newErrors.add(BoardValidationColorError(r.key, r.value,
                  BoardValidationErrorType.colorNotInOrder, newColor));
              newColorOrder.add(newColor);
            }
          } else {
            newColorOrder.add(newColor);
            var sequences = newRules.where((e) => faces.contains(e.key) && e.value is SequenceRule);
            for (var s in sequences) {
              (s.value as SequenceRule).colors.remove(newColor);
            }
          }
          var currentTrail =
              getColorTrail(trail, newRules, newColorOrder, previousFaces);
          currentTrail.trail.add(ColorTrailItem(
              ColorTrailReason.RuleSelected,
              hex: current, rule: r.value, color: newColor, errors: newErrors));
          best = best ?? currentTrail;
          best = (best.errors.length < currentTrail.errors.length
              ? best
              : currentTrail);
          if (best.errors.isEmpty) {
            return best;
          }
        }
        return best!;
      }
    } else {
      rules.removeWhere((e) =>
          e.value is SequenceRule && (e.value as SequenceRule).colors.isEmpty);
      if (rules.isNotEmpty) {
        var finalErrors = rules
            .where((e) => !(e.value is SequenceRule))
            .map((e) => BoardValidationError(
                e.key, e.value, BoardValidationErrorType.colorNotSatisfied))
            .toList();

        for (var r in rules.where((r) => r.value is SequenceRule)) {
          for (var c in (r.value as SequenceRule).colors) {
            finalErrors.add(BoardValidationColorError(
                r.key, r.value, BoardValidationErrorType.colorNotSatisfied, c));
          }
        }

        return ColorTrail.end(ColorTrailItem(ColorTrailReason.End, errors: finalErrors));
      }
      return ColorTrail();
    }
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

    var copyOfSequenceRules = _board
        .getPiece<SequenceRule>()
        .map((e) => new MapEntry<Hex, SequenceRule>(
            e.key, e.value.clone() as SequenceRule))
        .toList();
    List<Hex> previousFaces = [];
    for (var trail in _board.trail) {
      var dot =
          _board.getPiece<DotRule>().singleWhereOrNull((d) => d.key == trail);
      if (dot != null) {
        addColor(trail, dot.value);
      }
      if (trail.runtimeType == Edge) {
        var edgeRules = _board.getPiece<EdgeRule>().where(
            (e) => e.key == trail || ((e.key as Edge).parallelEdge == trail));
        var dotRules = _board.getPiece<DotRule>().where((e) => e.key == trail);
        var coloredRules = List<MapEntry<Hex, ColoredRule>>.from(dotRules)
          ..addAll(edgeRules);
        if (coloredRules.isNotEmpty) {
          if (coloredRules.length == 1) {
            addColor(trail, coloredRules.single.value);
          } else {
            if (previousColors.isNotEmpty) {
              coloredRules = coloredRules
                  .where((r) => r.value.color != previousColors.last)
                  .toList();
            }
            if (coloredRules
                .any((r) => r.value.color != coloredRules.first.value.color)) {
              for (var rule in coloredRules) {
                colorErrors.add(BoardValidationError(rule.key, rule.value,
                    BoardValidationErrorType.differentColorOverlap));
              }
            } else {
              addColor(trail, coloredRules.first.value);
            }
          }
        }
      }
      var currentFaces = trail.faces;
      var sequenceRules =
          copyOfSequenceRules.where((e) => currentFaces.contains(e.key));
      if (sequenceRules.isNotEmpty) {
        if (previousColors.isEmpty) {
          if (sequenceRules.every((r) => r.value.colors
              .every((c) => c == sequenceRules.first.value.colors.first))) {
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
        if (previousColors.isNotEmpty) {
          for (var sequenceRule in sequenceRules) {
            if (!previousFaces.contains(sequenceRule.key)) {
              if (sequenceRule.value.colors.isEmpty) {
                colorErrors.add(new BoardValidationError(
                    sequenceRule.key,
                    sequenceRule.value,
                    BoardValidationErrorType.noColorsRemaining));
              } else if (!sequenceRule.value.colors
                  .remove(previousColors.last)) {
                colorErrors.add(new BoardValidationColorError(
                    sequenceRule.key,
                    sequenceRule.value,
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
          colorErrors.add(new BoardValidationColorError(
              sequenceRule.key,
              sequenceRule.value,
              BoardValidationErrorType.colorNotSatisfied,
              colorIndex));
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
      if (traversed != expected) {
        edgeErrors.add(BoardValidationError(
            edge,
            edgePiece,
            traversed < expected
                ? BoardValidationErrorType.edgeNotTraversed
                : BoardValidationErrorType.tooManyEdges));
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
      int traversed =
          corners.where((Vertex v) => _board.trail.contains(v)).toList().length;
      if (traversed != expected) {
        cornerErrors.add(BoardValidationError(
            edge,
            cornerRule,
            traversed < expected
                ? BoardValidationErrorType.cornerNotTraversed
                : BoardValidationErrorType.tooManyCorners));
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
  BoardValidationColorError(
      Hex hex, Piece piece, BoardValidationErrorType error, this.color)
      : super(hex, piece, error);

  @override
  String toString() {
    return "${super.toString()} with ${color} color";
  }
}
