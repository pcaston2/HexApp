import 'package:flutter_guid/flutter_guid.dart';
import 'package:json_annotation/json_annotation.dart';

import 'board.dart';

part 'boardFlow.g.dart';

@JsonSerializable()
class BoardFlow {
  String name;
  @JsonKey(ignore: true)
  Guid _guid;

  String get guid {
    return _guid.value;
  }

  set guid(String value) {
    _guid = new Guid(value);
  }

  List<String> boards;

  BoardFlow() : this.named("Untitled");

  BoardFlow.named(this.name)
  {
    _guid = Guid.newGuid;
  }

  factory BoardFlow.fromJson(Map<String, dynamic> json) => _$BoardFlowFromJson(json);

  Map<String, dynamic> toJson() => _$BoardFlowToJson(this);

  String toString() {
    return name;
  }
}