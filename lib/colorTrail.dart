import 'board.dart';
import 'boardTheme.dart';
import 'hex.dart';

class ColorTrail {
  late Map<Hex, RuleColorIndex> trail;
  bool get valid {
    return errors.isEmpty;
  }
  late List<BoardValidationError> errors;

  ColorTrail() {
    trail = Map();
    errors = [];
  }

  ColorTrail.Invalid(List<BoardValidationError> e) {
    trail = Map();
    errors = e;
  }
}