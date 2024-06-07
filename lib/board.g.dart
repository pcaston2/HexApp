// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Board _$BoardFromJson(Map<String, dynamic> json) => Board()
  ..name = json['name'] as String
  ..completed = json['completed'] as bool
  ..map = (json['map'] as List<dynamic>)
      .map((e) => HexPieceEntry.fromJson(e as Map<String, dynamic>))
      .toList()
  ..theme = BoardTheme.fromJson(json['theme'] as Map<String, dynamic>)
  ..tutorial = json['tutorial'] as bool
  ..size = json['size'] as int
  ..guid = json['guid'] as String;

Map<String, dynamic> _$BoardToJson(Board instance) => <String, dynamic>{
      'name': instance.name,
      'completed': instance.completed,
      'map': instance.map.map((e) => e.toJson()).toList(),
      'theme': instance.theme.toJson(),
      'tutorial': instance.tutorial,
      'size': instance.size,
      'guid': instance.guid,
    };

HexPieceEntry _$HexPieceEntryFromJson(Map<String, dynamic> json) =>
    HexPieceEntry()
      ..hex = Hex.fromJson(json['hex'] as Map<String, dynamic>)
      ..piece = Piece.fromJson(json['piece'] as Map<String, dynamic>);

Map<String, dynamic> _$HexPieceEntryToJson(HexPieceEntry instance) =>
    <String, dynamic>{
      'hex': instance.hex.toJson(),
      'piece': instance.piece.toJson(),
    };
