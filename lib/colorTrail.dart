import 'dart:io';

import 'package:collection/collection.dart';
import 'package:hex_game/piece.dart';

import 'board.dart';
import 'boardTheme.dart';
import 'hex.dart';

enum ColorTrailReason {
  Skip, SequenceColorVariation,
  SequenceColorFound,
  ColorNotInSequence, NoColorsInSequence, SequenceColorSelected, RuleSelected, End
}

class ColorTrail {
  late List<ColorTrailItem> trail;
  bool get valid {
    return errors.isEmpty;
  }
   List<BoardValidationError> get errors {
    return trail.map((e) => e.errors).flattened.toList();
   }

  ColorTrail() {
    trail = [];
  }

  ColorTrail.end(ColorTrailItem trailEnd) {
    trail = [];
    trail.add(trailEnd);
  }

  @override
  String toString() {
    var s = "";
    var i = 0;
    for (var t in trail.reversed) {
      i++;
      s += "STEP ${i}: ${t.reason.name}${Platform.lineTerminator}";
      if (t.hex != null) {
        s += "Hex: ${t.hex}${Platform.lineTerminator}";
      }
      if (t.color != null) {
        s+= "Color: ${t.color}${Platform.lineTerminator}";
      }
      if (t.rule != null) {
        s+= "Rule: ${t.rule.toString()}${Platform.lineTerminator}";
      }
      if (t.errors.isNotEmpty) {
        s += "Errors: ${t.errors.toString()}${Platform.lineTerminator}";
      }
      s += Platform.lineTerminator;
    }
    if (errors.isNotEmpty) {
      s += "Errors:${Platform.lineTerminator}";
      for (var e in errors) {
        s += e.toString() + Platform.lineTerminator;
      }
    }
    return s;
  }
}

class ColorTrailItem {
  late ColorTrailReason reason;
  late List<BoardValidationError> errors;
  late Hex? hex;
  late Rule? rule;
  late RuleColorIndex? color;

  ColorTrailItem(this.reason, {this.hex = null, this.rule, this.color = null, this.errors = const[]}) {

  }
}