// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boardTheme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardTheme _$BoardThemeFromJson(Map<String, dynamic> json) {
  return BoardTheme()
    ..background = json['background'] == null
        ? null
        : Color.fromJson(json['background'] as Map<String, dynamic>)
    ..border = json['border'] == null
        ? null
        : Color.fromJson(json['border'] as Map<String, dynamic>)
    ..panel = json['panel'] == null
        ? null
        : Color.fromJson(json['panel'] as Map<String, dynamic>)
    ..path = json['path'] == null
        ? null
        : Color.fromJson(json['path'] as Map<String, dynamic>)
    ..trail = json['trail'] == null
        ? null
        : Color.fromJson(json['trail'] as Map<String, dynamic>)
    ..ruleColors = (json['ruleColors'] as List)
        ?.map(
            (e) => e == null ? null : Color.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$BoardThemeToJson(BoardTheme instance) =>
    <String, dynamic>{
      'background': instance.background,
      'border': instance.border,
      'panel': instance.panel,
      'path': instance.path,
      'trail': instance.trail,
      'ruleColors': instance.ruleColors,
    };
