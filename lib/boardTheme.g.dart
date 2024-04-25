// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boardTheme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardTheme _$BoardThemeFromJson(Map<String, dynamic> json) => BoardTheme()
  ..background = Color.fromJson(json['background'] as Map<String, dynamic>)
  ..border = Color.fromJson(json['border'] as Map<String, dynamic>)
  ..foreground = Color.fromJson(json['foreground'] as Map<String, dynamic>)
  ..path = Color.fromJson(json['path'] as Map<String, dynamic>)
  ..trail = Color.fromJson(json['trail'] as Map<String, dynamic>)
  ..ruleColors = (json['ruleColors'] as Map<String, dynamic>).map(
    (k, e) => MapEntry($enumDecode(_$RuleColorIndexEnumMap, k),
        Color.fromJson(e as Map<String, dynamic>)),
  );

Map<String, dynamic> _$BoardThemeToJson(BoardTheme instance) =>
    <String, dynamic>{
      'background': instance.background.toJson(),
      'border': instance.border.toJson(),
      'foreground': instance.foreground.toJson(),
      'path': instance.path.toJson(),
      'trail': instance.trail.toJson(),
      'ruleColors': instance.ruleColors
          .map((k, e) => MapEntry(_$RuleColorIndexEnumMap[k]!, e.toJson())),
    };

const _$RuleColorIndexEnumMap = {
  RuleColorIndex.First: 'First',
  RuleColorIndex.Second: 'Second',
  RuleColorIndex.Third: 'Third',
  RuleColorIndex.Fourth: 'Fourth',
  RuleColorIndex.Fifth: 'Fifth',
};
