// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathPiece _$PathPieceFromJson(Map<String, dynamic> json) {
  return PathPiece();
}

Map<String, dynamic> _$PathPieceToJson(PathPiece instance) =>
    <String, dynamic>{};

ErasePiece _$ErasePieceFromJson(Map<String, dynamic> json) {
  return ErasePiece();
}

Map<String, dynamic> _$ErasePieceToJson(ErasePiece instance) =>
    <String, dynamic>{};

StartPiece _$StartPieceFromJson(Map<String, dynamic> json) {
  return StartPiece();
}

Map<String, dynamic> _$StartPieceToJson(StartPiece instance) =>
    <String, dynamic>{};

EndPiece _$EndPieceFromJson(Map<String, dynamic> json) {
  return EndPiece();
}

Map<String, dynamic> _$EndPieceToJson(EndPiece instance) => <String, dynamic>{};

DotRule _$DotRuleFromJson(Map<String, dynamic> json) {
  return DotRule()
    ..color = _$enumDecodeNullable(_$RuleColorIndexEnumMap, json['color']);
}

Map<String, dynamic> _$DotRuleToJson(DotRule instance) => <String, dynamic>{
      'color': _$RuleColorIndexEnumMap[instance.color],
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

BreakRule _$BreakRuleFromJson(Map<String, dynamic> json) {
  return BreakRule();
}

Map<String, dynamic> _$BreakRuleToJson(BreakRule instance) =>
    <String, dynamic>{};

EdgeRule _$EdgeRuleFromJson(Map<String, dynamic> json) {
  return EdgeRule()..count = json['count'] as int;
}

Map<String, dynamic> _$EdgeRuleToJson(EdgeRule instance) => <String, dynamic>{
      'count': instance.count,
    };
