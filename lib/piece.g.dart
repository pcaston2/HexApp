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

DotRulePiece _$DotRulePieceFromJson(Map<String, dynamic> json) {
  return DotRulePiece();
}

Map<String, dynamic> _$DotRulePieceToJson(DotRulePiece instance) =>
    <String, dynamic>{};

BreakRulePiece _$BreakRulePieceFromJson(Map<String, dynamic> json) {
  return BreakRulePiece();
}

Map<String, dynamic> _$BreakRulePieceToJson(BreakRulePiece instance) =>
    <String, dynamic>{};

EdgeRulePiece _$EdgeRulePieceFromJson(Map<String, dynamic> json) {
  return EdgeRulePiece()..count = json['count'] as int;
}

Map<String, dynamic> _$EdgeRulePieceToJson(EdgeRulePiece instance) =>
    <String, dynamic>{
      'count': instance.count,
    };
