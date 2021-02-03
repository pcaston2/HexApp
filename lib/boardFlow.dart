import 'dart:convert';
import 'dart:io';

import 'package:flutter_guid/flutter_guid.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

import 'board.dart';

part 'boardFlow.g.dart';


const String FLOW_FILE_EXTENSION = "jhexflow";

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

  List<String> boardPaths = [];

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


  static Future<BoardFlow> createFlow(String flowName) async {
    BoardFlow flow = new BoardFlow.named(flowName);
    await flow.save();
    return flow;
  }

  Future<void> save() async {
    var cacheDir = await getApplicationDocumentsDirectory();
    File f = File('${cacheDir.path}/flow_$guid.$FLOW_FILE_EXTENSION');
    f.writeAsString(json.encode(toJson()));
  }

  Future<List<Board>> get boards async {
    Directory cacheDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = cacheDir.listSync();
    var flowFiles = files.where((FileSystemEntity entity) =>
        entity.path.contains(".$BOARD_FILE_EXTENSION"));
    List<Board> boards = [];
    for (FileSystemEntity fse in flowFiles) {
      try {
        File file = File(fse.path);
        String s = await file.readAsString();
        boards.add(Board.fromJson(json.decode(s)));
      } on Exception catch (ex) {
        print(ex);
      }
    }
    return boards;
  }

  static Future<List<BoardFlow>> getFlows() async {
    Directory cacheDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = cacheDir.listSync();
    var flowFiles = files.where((FileSystemEntity entity) =>
        entity.path.contains(".$FLOW_FILE_EXTENSION"));
    List<BoardFlow> flows = [];
    for (FileSystemEntity fse in flowFiles) {
      try {
        File file = File(fse.path);
        String s = await file.readAsString();
        flows.add(BoardFlow.fromJson(json.decode(s)));
      } on Exception catch (ex) {
        print(ex);
      }
    }
    return flows;
  }
}