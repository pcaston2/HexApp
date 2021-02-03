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
    ..foreground = json['foreground'] == null
        ? null
        : Color.fromJson(json['foreground'] as Map<String, dynamic>)
    ..path = json['path'] == null
        ? null
        : Color.fromJson(json['path'] as Map<String, dynamic>)
    ..trail = json['trail'] == null
        ? null
        : Color.fromJson(json['trail'] as Map<String, dynamic>)
    ..ruleColors = (json['ruleColors'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(_$enumDecodeNullable(_$RuleColorIndexEnumMap, k),
          e == null ? null : Color.fromJson(e as Map<String, dynamic>)),
    );
}

Map<String, dynamic> _$BoardThemeToJson(BoardTheme instance) =>
    <String, dynamic>{
      'background': instance.background,
      'border': instance.border,
      'foreground': instance.foreground,
      'path': instance.path,
      'trail': instance.trail,
      'ruleColors': instance.ruleColors
          ?.map((k, e) => MapEntry(_$RuleColorIndexEnumMap[k], e)),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$RuleColorIndexEnumMap = {
  RuleColorIndex.First: 'First',
  RuleColorIndex.Second: 'Second',
  RuleColorIndex.Third: 'Third',
  RuleColorIndex.Fourth: 'Fourth',
  RuleColorIndex.Fifth: 'Fifth',
};
