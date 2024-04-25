// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hex _$HexFromJson(Map<String, dynamic> json) => Hex()
  ..q = json['q'] as int
  ..r = json['r'] as int;

Map<String, dynamic> _$HexToJson(Hex instance) => <String, dynamic>{
      'q': instance.q,
      'r': instance.r,
    };

Vertex _$VertexFromJson(Map<String, dynamic> json) => Vertex()
  ..q = json['q'] as int
  ..r = json['r'] as int
  ..vertexType = $enumDecode(_$VertexTypeEnumMap, json['vertexType']);

Map<String, dynamic> _$VertexToJson(Vertex instance) => <String, dynamic>{
      'q': instance.q,
      'r': instance.r,
      'vertexType': _$VertexTypeEnumMap[instance.vertexType]!,
    };

const _$VertexTypeEnumMap = {
  VertexType.East: 'East',
  VertexType.West: 'West',
};

Edge _$EdgeFromJson(Map<String, dynamic> json) => Edge()
  ..q = json['q'] as int
  ..r = json['r'] as int
  ..edgeType = $enumDecode(_$EdgeTypeEnumMap, json['edgeType']);

Map<String, dynamic> _$EdgeToJson(Edge instance) => <String, dynamic>{
      'q': instance.q,
      'r': instance.r,
      'edgeType': _$EdgeTypeEnumMap[instance.edgeType]!,
    };

const _$EdgeTypeEnumMap = {
  EdgeType.East: 'East',
  EdgeType.North: 'North',
  EdgeType.West: 'West',
};
