import 'color.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart' as mat;
import 'matColorExtension.dart' as ext;

part 'boardTheme.g.dart';

enum RuleColorIndex {
  First,
  Second,
  Third,
  Fourth,
  Fifth
}

@JsonSerializable(explicitToJson: true)
class BoardTheme {
  Color background = new Color();
  Color border = new Color();
  Color foreground = new Color();
  Color path = new Color();
  Color trail = new Color();

  Map<RuleColorIndex, Color> ruleColors = {
    RuleColorIndex.First: Color.from(mat.Colors.grey[600]!),
    RuleColorIndex.Second: Color.from(mat.Colors.orangeAccent),
    RuleColorIndex.Third: Color.from(mat.Colors.redAccent),
    RuleColorIndex.Fourth: Color.from(mat.Colors.lightGreenAccent),
    RuleColorIndex.Fifth: Color.from(mat.Colors.deepPurpleAccent),
  };

  BoardTheme.yellow() {
    background.value = mat.Colors.lightGreen[100]!;
    border.value = ext.HexColor.fromHex("#ff60717e");
    foreground.value = ext.HexColor.fromHex("#fffbea52");
    path.value = ext.HexColor.fromHex("#ff413b29");
    trail.value = ext.HexColor.fromHex("#fff9f7a6");
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.blueGrey[500]!;
    ruleColors[RuleColorIndex.Second]!.value = mat.Colors.orangeAccent;
    ruleColors[RuleColorIndex.Third]!.value = mat.Colors.redAccent;
    ruleColors[RuleColorIndex.Fourth]!.value = mat.Colors.lightGreenAccent;
    ruleColors[RuleColorIndex.Fifth]!.value = mat.Colors.deepPurpleAccent;
  }

  BoardTheme.blue() {
    background.value = mat.Colors.white;
    border.value = mat.Colors.black;
    foreground.value = mat.Colors.lightBlue;
    path.value = mat.Colors.blueGrey;
    trail.value = mat.Colors.amberAccent;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.grey[800]!;
    ruleColors[RuleColorIndex.Second]!.value = mat.Colors.orangeAccent;
    ruleColors[RuleColorIndex.Third]!.value = mat.Colors.redAccent;
    ruleColors[RuleColorIndex.Fourth]!.value = mat.Colors.lightGreenAccent;
    ruleColors[RuleColorIndex.Fifth]!.value = mat.Colors.deepPurpleAccent;
  }

  BoardTheme.red() {
    background.value = mat.Colors.amber[100]!;
    border.value = mat.Colors.blueGrey[800]!;
    foreground.value = mat.Colors.red[600]!;
    path.value = mat.Colors.red[900]!;
    trail.value = mat.Colors.yellow;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.grey[800]!;
    ruleColors[RuleColorIndex.Second]!.value = ext.HexColor.fromHex("#D5D520");
    ruleColors[RuleColorIndex.Third]!.value = ext.HexColor.fromHex("#20D58B");
    ruleColors[RuleColorIndex.Fourth]!.value = ext.HexColor.fromHex("#209BD5");
    ruleColors[RuleColorIndex.Fifth]!.value = ext.HexColor.fromHex("#F10C9E");
  }

  BoardTheme.gray() {
    background.value = mat.Colors.brown[200]!;
    border.value = mat.Colors.blueGrey[600]!;
    foreground.value = mat.Colors.grey[50]!;
    path.value = mat.Colors.grey[600]!;
    trail.value = mat.Colors.yellow;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.grey[800]!;
    ruleColors[RuleColorIndex.Second]!.value = ext.HexColor.fromHex("#D5D520");
    ruleColors[RuleColorIndex.Third]!.value = ext.HexColor.fromHex("#20D58B");
    ruleColors[RuleColorIndex.Fourth]!.value = ext.HexColor.fromHex("#209BD5");
    ruleColors[RuleColorIndex.Fifth]!.value = ext.HexColor.fromHex("#F10C9E");
  }

  BoardTheme.green() {
    background.value = mat.Colors.amberAccent[100]!;
    border.value = mat.Colors.grey[600]!;
    foreground.value = mat.Colors.lightGreen[400]!;
    path.value = mat.Colors.grey[800]!;
    trail.value = mat.Colors.yellow;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.grey[500]!;
    ruleColors[RuleColorIndex.Second]!.value = ext.HexColor.fromHex("#D5D520");
    ruleColors[RuleColorIndex.Third]!.value = ext.HexColor.fromHex("#20D58B");
    ruleColors[RuleColorIndex.Fourth]!.value = ext.HexColor.fromHex("#209BD5");
    ruleColors[RuleColorIndex.Fifth]!.value = ext.HexColor.fromHex("#F10C9E");
  }

  BoardTheme.shale() {
    background.value = ext.HexColor.fromHex("#493c3c");
    border.value = mat.Colors.grey[600]!;
    foreground.value = mat.Colors.blueGrey[800]!;
    path.value = mat.Colors.tealAccent[700]!;
    trail.value = mat.Colors.grey[200]!;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.grey[500]!;
    ruleColors[RuleColorIndex.Second]!.value = ext.HexColor.fromHex("#D5D520");
    ruleColors[RuleColorIndex.Third]!.value = ext.HexColor.fromHex("#20D58B");
    ruleColors[RuleColorIndex.Fourth]!.value = ext.HexColor.fromHex("#209BD5");
    ruleColors[RuleColorIndex.Fifth]!.value = ext.HexColor.fromHex("#F10C9E");
  }

  BoardTheme.orangeAccent() {
    background.value = mat.Colors.lightGreen[600]!;
    border.value = mat.Colors.orangeAccent[400]!;
    foreground.value = mat.Colors.grey[500]!;
    path.value = mat.Colors.blueGrey;
    trail.value = mat.Colors.orange;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.brown[300]!;
    ruleColors[RuleColorIndex.Second]!.value = ext.HexColor.fromHex("#D5D520");
    ruleColors[RuleColorIndex.Third]!.value = ext.HexColor.fromHex("#20D58B");
    ruleColors[RuleColorIndex.Fourth]!.value = ext.HexColor.fromHex("#209BD5");
    ruleColors[RuleColorIndex.Fifth]!.value = ext.HexColor.fromHex("#F10C9E");
  }

  BoardTheme.purpleAccent() {
    background.value = mat.Colors.grey[700]!;
    border.value = mat.Colors.purple;
    foreground.value = mat.Colors.blueGrey[500]!;
    path.value = mat.Colors.grey[700]!;
    trail.value = mat.Colors.purpleAccent[400]!;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.brown[300]!;
    ruleColors[RuleColorIndex.Second]!.value = ext.HexColor.fromHex("#D5D520");
    ruleColors[RuleColorIndex.Third]!.value = ext.HexColor.fromHex("#20D58B");
    ruleColors[RuleColorIndex.Fourth]!.value = ext.HexColor.fromHex("#209BD5");
    ruleColors[RuleColorIndex.Fifth]!.value = ext.HexColor.fromHex("#F10C9E");
  }

  BoardTheme.greenAccent() {
    background.value = mat.Colors.brown[300]!;
    border.value = mat.Colors.green;
    foreground.value = mat.Colors.blueGrey[300]!;
    path.value = mat.Colors.grey[600]!;
    trail.value = mat.Colors.greenAccent[400]!;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.brown[300]!;
    ruleColors[RuleColorIndex.Second]!.value = ext.HexColor.fromHex("#D5D520");
    ruleColors[RuleColorIndex.Third]!.value = ext.HexColor.fromHex("#20D58B");
    ruleColors[RuleColorIndex.Fourth]!.value = ext.HexColor.fromHex("#209BD5");
    ruleColors[RuleColorIndex.Fifth]!.value = ext.HexColor.fromHex("#F10C9E");
  }

  BoardTheme.mustard() {
    background.value = mat.Colors.teal[900]!;
    border.value = mat.Colors.lime[800]!;
    foreground.value = mat.Colors.lightGreen[300]!;
    path.value = mat.Colors.lime[300]!;
    trail.value = mat.Colors.limeAccent;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.brown[300]!;
    ruleColors[RuleColorIndex.Second]!.value = ext.HexColor.fromHex("#D5D520");
    ruleColors[RuleColorIndex.Third]!.value = ext.HexColor.fromHex("#20D58B");
    ruleColors[RuleColorIndex.Fourth]!.value = ext.HexColor.fromHex("#209BD5");
    ruleColors[RuleColorIndex.Fifth]!.value = ext.HexColor.fromHex("#F10C9E");
  }

  BoardTheme.highContrast() {
    background.value = mat.Colors.black;
    border.value = mat.Colors.grey[100]!;
    foreground.value = mat.Colors.grey[900]!;
    path.value = mat.Colors.white;
    trail.value = mat.Colors.grey[500]!;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.cyanAccent;
    ruleColors[RuleColorIndex.Second]!.value = mat.Colors.purpleAccent;
    ruleColors[RuleColorIndex.Third]!.value = mat.Colors.orangeAccent;
    ruleColors[RuleColorIndex.Fourth]!.value = mat.Colors.greenAccent;
    ruleColors[RuleColorIndex.Fifth]!.value = mat.Colors.yellowAccent;
  }

  BoardTheme.brown() {
    background.value = ext.HexColor.fromHex("#efccaa");
    border.value = mat.Colors.blueGrey[800]!;
    foreground.value = ext.HexColor.fromHex("#E77D22");
    path.value = ext.HexColor.fromHex("#482700");
    trail.value = mat.Colors.yellow;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.blueGrey[500]!;
    ruleColors[RuleColorIndex.Second]!.value = mat.Colors.orangeAccent;
    ruleColors[RuleColorIndex.Third]!.value = mat.Colors.redAccent;
    ruleColors[RuleColorIndex.Fourth]!.value = mat.Colors.lightGreenAccent;
    ruleColors[RuleColorIndex.Fifth]!.value = mat.Colors.deepPurpleAccent;
  }

  BoardTheme.darkBlue() {
    background.value = mat.Colors.lightGreen[400]!;
    border.value = mat.Colors.grey[800]!;
    foreground.value = mat.Colors.indigoAccent[700]!;
    path.value = mat.Colors.indigo[600]!;
    trail.value = mat.Colors.blue[50]!;
    ruleColors[RuleColorIndex.First]!.value = mat.Colors.grey[800]!;
    ruleColors[RuleColorIndex.Second]!.value = mat.Colors.orangeAccent;
    ruleColors[RuleColorIndex.Third]!.value = mat.Colors.redAccent;
    ruleColors[RuleColorIndex.Fourth]!.value = mat.Colors.lightGreenAccent;
    ruleColors[RuleColorIndex.Fifth]!.value = mat.Colors.deepPurpleAccent;
  }

  factory BoardTheme() {
    return BoardTheme.yellow();
  }

  factory BoardTheme.fromJson(Map<String, dynamic> json) => _$BoardThemeFromJson(json);

  Map<String, dynamic> toJson() => _$BoardThemeToJson(this);
}