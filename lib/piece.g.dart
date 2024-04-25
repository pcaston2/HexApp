// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathPiece _$PathPieceFromJson(Map<String, dynamic> json) => PathPiece();

Map<String, dynamic> _$PathPieceToJson(PathPiece instance) =>
    <String, dynamic>{};

ErasePiece _$ErasePieceFromJson(Map<String, dynamic> json) => ErasePiece();

Map<String, dynamic> _$ErasePieceToJson(ErasePiece instance) =>
    <String, dynamic>{};

StartPiece _$StartPieceFromJson(Map<String, dynamic> json) => StartPiece();

Map<String, dynamic> _$StartPieceToJson(StartPiece instance) =>
    <String, dynamic>{};

EndPiece _$EndPieceFromJson(Map<String, dynamic> json) => EndPiece();

Map<String, dynamic> _$EndPieceToJson(EndPiece instance) => <String, dynamic>{};

DotRule _$DotRuleFromJson(Map<String, dynamic> json) =>
    DotRule()..color = $enumDecode(_$RuleColorIndexEnumMap, json['color']);

Map<String, dynamic> _$DotRuleToJson(DotRule instance) => <String, dynamic>{
      'color': _$RuleColorIndexEnumMap[instance.color]!,
    };

const _$RuleColorIndexEnumMap = {
  RuleColorIndex.First: 'First',
  RuleColorIndex.Second: 'Second',
  RuleColorIndex.Third: 'Third',
  RuleColorIndex.Fourth: 'Fourth',
  RuleColorIndex.Fifth: 'Fifth',
};

BreakRule _$BreakRuleFromJson(Map<String, dynamic> json) => BreakRule();

Map<String, dynamic> _$BreakRuleToJson(BreakRule instance) =>
    <String, dynamic>{};

EdgeRule _$EdgeRuleFromJson(Map<String, dynamic> json) =>
    EdgeRule()..count = json['count'] as int;

Map<String, dynamic> _$EdgeRuleToJson(EdgeRule instance) => <String, dynamic>{
      'count': instance.count,
    };
