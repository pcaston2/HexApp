// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Story _$StoryFromJson(Map<String, dynamic> json) => Story()
  ..name = json['name'] as String
  ..completed = json['completed'] as bool
  ..guid = json['guid'] as String
  ..flowPaths =
      (json['flowPaths'] as List<dynamic>).map((e) => e as String).toList();

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
      'name': instance.name,
      'completed': instance.completed,
      'guid': instance.guid,
      'flowPaths': instance.flowPaths,
    };
