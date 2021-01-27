// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hex _$HexFromJson(Map<String, dynamic> json) {
  return Hex()
    ..q = json['q'] as int
    ..r = json['r'] as int;
}

Map<String, dynamic> _$HexToJson(Hex instance) => <String, dynamic>{
      'q': instance.q,
      'r': instance.r,
    };

Vertex _$VertexFromJson(Map<String, dynamic> json) {
  return Vertex()
    ..q = json['q'] as int
    ..r = json['r'] as int
    ..vertexType =
        _$enumDecodeNullable(_$VertexTypeEnumMap, json['vertexType']);
}

Map<String, dynamic> _$VertexToJson(Vertex instance) => <String, dynamic>{
      'q': instance.q,
      'r': instance.r,
      'vertexType': _$VertexTypeEnumMap[instance.vertexType],
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

const _$VertexTypeEnumMap = {
  VertexType.East: 'East',
  VertexType.West: 'West',
};

Edge _$EdgeFromJson(Map<String, dynamic> json) {
  return Edge()
    ..q = json['q'] as int
    ..r = json['r'] as int
    ..edgeType = _$enumDecodeNullable(_$EdgeTypeEnumMap, json['edgeType']);
}

Map<String, dynamic> _$EdgeToJson(Edge instance) => <String, dynamic>{
      'q': instance.q,
      'r': instance.r,
      'edgeType': _$EdgeTypeEnumMap[instance.edgeType],
    };

const _$EdgeTypeEnumMap = {
  EdgeType.East: 'East',
  EdgeType.North: 'North',
  EdgeType.West: 'West',
};
