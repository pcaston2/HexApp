// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boardFlow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardFlow _$BoardFlowFromJson(Map<String, dynamic> json) {
  return BoardFlow()
    ..name = json['name'] as String
    ..guid = json['guid'] as String
    ..boards = (json['boards'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$BoardFlowToJson(BoardFlow instance) => <String, dynamic>{
      'name': instance.name,
      'guid': instance.guid,
      'boards': instance.boards,
    };
