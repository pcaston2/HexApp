import 'package:flutter/material.dart' as mat;
import 'matColorExtension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'color.g.dart';

@JsonSerializable(explicitToJson: true)
class Color {
  late mat.Color _color;

  @JsonKey(includeFromJson: false, includeToJson: false)
  mat.Color get value {
    return _color;
  }

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
    if (percent < 0) {
      return brighten(-percent);
    }

    var f = 1 - percent / 100;
    return Color.from(mat.Color.fromARGB(
        (value.a * 255.0 * f).round().clamp(0,255),
        (value.r * 255.0 * f).round().clamp(0,255),
        (value.g * 255.0 * f).round().clamp(0,255),
        (value.b * 255.0 * f).round().clamp(0,255)));
  }

  Color brighten([int percent = 10]) {
    if (percent < 0) {
      return darken(-percent);
    }
    var p = percent / 100;
    return Color.from(mat.Color.fromARGB(
        (value.a * 255.0).round().clamp(0,255),
        (value.r * 255.0).round().clamp(0,255) + ((255 - (value.r * 255.0).round().clamp(0,255)) * p).round(),
        (value.g * 255.0).round().clamp(0,255) + ((255 - (value.g * 255.0).round().clamp(0,255)) * p).round(),
        (value.b * 255.0).round().clamp(0,255) + ((255 - (value.b * 255.0).round().clamp(0,255)) * p).round()));
  }
}
