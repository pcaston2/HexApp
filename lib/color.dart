import 'package:flutter/material.dart' as mat;
import 'matColorExtension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'color.g.dart';

@JsonSerializable()
class Color {
  mat.Color _color;

  @JsonKey(ignore: true)
  mat.Color get value {
    return _color;
  }

  @JsonKey(ignore: true)
  set value(mat.Color color) {
    _color = color;
  }

  String get hexCode {
    return _color.toHex();
  }

  set hexCode(String hexCode) {
    _color = HexColor.fromHex(hexCode);
  }

  Color() {
    value = mat.Colors.white;
  }

  Color.from(mat.Color color) {
    value = color;
  }

  factory Color.fromJson(Map<String, dynamic> json) => _$ColorFromJson(json);

  Map<String, dynamic> toJson() => _$ColorToJson(this);

  Color darken([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.from(mat.Color.fromARGB(value.alpha, (value.red * f).round(),
        (value.green * f).round(), (value.blue * f).round()));
  }

  Color brighten([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.from(mat.Color.fromARGB(
        value.alpha,
        value.red + ((255 - value.red) * p).round(),
        value.green + ((255 - value.green) * p).round(),
        value.blue + ((255 - value.blue) * p).round()));
  }
}
