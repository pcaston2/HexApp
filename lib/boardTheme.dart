import 'color.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart' as mat;

part 'boardTheme.g.dart';

enum RuleColorIndex {
  First,
  Second,
  Third,
  Fourth,
  Fifth
}

@JsonSerializable()
class BoardTheme {
  Color background = new Color();
  Color border = new Color();
  Color foreground = new Color();
  Color path = new Color();
  Color trail = new Color();

  Map<RuleColorIndex, Color> ruleColors = {
  RuleColorIndex.First: Color.from(mat.Colors.orangeAccent),
  RuleColorIndex.Second: Color.from(mat.Colors.redAccent),
  RuleColorIndex.Third: Color.from(mat.Colors.lightGreenAccent),
  RuleColorIndex.Fourth: Color.from(mat.Colors.deepPurpleAccent),
  RuleColorIndex.Fifth: Color.from(mat.Colors.indigoAccent),
  };

  BoardTheme.blue() {
    background.value = mat.Colors.white;
    border.value = mat.Colors.black;
    foreground.value = mat.Colors.lightBlue;
    path.value = mat.Colors.blueGrey;
    trail.value = mat.Colors.amberAccent;
    ruleColors[RuleColorIndex.First].value = mat.Colors.orangeAccent;
    ruleColors[RuleColorIndex.Second].value = mat.Colors.redAccent;
    ruleColors[RuleColorIndex.Third].value = mat.Colors.lightGreenAccent;
    ruleColors[RuleColorIndex.Fourth].value = mat.Colors.deepPurpleAccent;
    ruleColors[RuleColorIndex.Fifth].value = mat.Colors.indigoAccent;
  }

  BoardTheme.red() {
    background.value = mat.Colors.white;
    border.value = mat.Colors.grey;
    foreground.value = mat.Colors.red[600];
    path.value = mat.Colors.redAccent[200];
    trail.value = mat.Colors.yellow;
    ruleColors[RuleColorIndex.First].value = mat.Colors.orangeAccent;
    ruleColors[RuleColorIndex.Second].value = mat.Colors.redAccent;
    ruleColors[RuleColorIndex.Third].value = mat.Colors.lightGreenAccent;
    ruleColors[RuleColorIndex.Fourth].value = mat.Colors.deepPurpleAccent;
    ruleColors[RuleColorIndex.Fifth].value = mat.Colors.indigoAccent;
  }

  factory BoardTheme() {
    return BoardTheme.red();
  }

  factory BoardTheme.fromJson(Map<String, dynamic> json) => _$BoardThemeFromJson(json);

  Map<String, dynamic> toJson() => _$BoardThemeToJson(this);
}