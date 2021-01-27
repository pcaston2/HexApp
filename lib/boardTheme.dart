import 'color.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart' as mat;

part 'boardTheme.g.dart';

@JsonSerializable()
class BoardTheme {
  Color background = new Color();
  Color border = new Color();
  Color panel = new Color();
  Color path = new Color();
  Color trail = new Color();

  List<Color> ruleColors;

  BoardTheme.blue() {
    background.value = mat.Colors.white;
    border.value = mat.Colors.black;
    panel.value = mat.Colors.lightBlue;
    path.value = mat.Colors.blueGrey;
    trail.value = mat.Colors.amberAccent;
  }

  BoardTheme.red() {
    background.value = mat.Colors.white;
    border.value = mat.Colors.grey;
    panel.value = mat.Colors.red[600];
    path.value = mat.Colors.redAccent[200];
    trail.value = mat.Colors.yellow;
  }

  factory BoardTheme() {
    return BoardTheme.red();
  }

  factory BoardTheme.fromJson(Map<String, dynamic> json) => _$BoardThemeFromJson(json);

  Map<String, dynamic> toJson() => _$BoardThemeToJson(this);
}