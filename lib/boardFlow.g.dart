// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boardFlow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardFlow _$BoardFlowFromJson(Map<String, dynamic> json) => BoardFlow()
  ..name = json['name'] as String
  ..guid = json['guid'] as String
  ..boardPaths =
      (json['boardPaths'] as List<dynamic>).map((e) => e as String).toList();

Map<String, dynamic> _$BoardFlowToJson(BoardFlow instance) => <String, dynamic>{
      'name': instance.name,
      'guid': instance.guid,
      'boardPaths': instance.boardPaths,
    };
