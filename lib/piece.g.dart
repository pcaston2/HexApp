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

BreakPiece _$BreakPieceFromJson(Map<String, dynamic> json) => BreakPiece();

Map<String, dynamic> _$BreakPieceToJson(BreakPiece instance) =>
    <String, dynamic>{};

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

SequenceRule _$SequenceRuleFromJson(Map<String, dynamic> json) => SequenceRule()
  ..colors = (json['colors'] as List<dynamic>)
      .map((e) => $enumDecode(_$RuleColorIndexEnumMap, e))
      .toList();

Map<String, dynamic> _$SequenceRuleToJson(SequenceRule instance) =>
    <String, dynamic>{
      'colors':
          instance.colors.map((e) => _$RuleColorIndexEnumMap[e]!).toList(),
    };

EdgeRule _$EdgeRuleFromJson(Map<String, dynamic> json) => EdgeRule()
  ..color = $enumDecode(_$RuleColorIndexEnumMap, json['color'])
  ..count = json['count'] as int;

Map<String, dynamic> _$EdgeRuleToJson(EdgeRule instance) => <String, dynamic>{
      'color': _$RuleColorIndexEnumMap[instance.color]!,
      'count': instance.count,
    };

CornerRule _$CornerRuleFromJson(Map<String, dynamic> json) => CornerRule()
  ..color = $enumDecode(_$RuleColorIndexEnumMap, json['color'])
  ..count = json['count'] as int;

Map<String, dynamic> _$CornerRuleToJson(CornerRule instance) =>
    <String, dynamic>{
      'color': _$RuleColorIndexEnumMap[instance.color]!,
      'count': instance.count,
    };
