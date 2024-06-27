import 'dart:convert';
import 'dart:io';

import 'package:flutter_guid/flutter_guid.dart';
import 'package:hex_game/boardTheme.dart';
import 'settings.dart';
import 'package:json_annotation/json_annotation.dart';

import 'board.dart';

part 'boardFlow.g.dart';


const String FLOW_FILE_EXTENSION = "jhexflow";

@JsonSerializable()
class BoardFlow {
  String name;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Guid _guid;

  late bool completed;

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
    completed = false;
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
    var settings = await Settings.getInstance();
    File f = File('${settings.storagePath}/flow_$guid.$FLOW_FILE_EXTENSION');
    await f.writeAsString(json.encode(toJson()));
  }


  Future<void> deleteAt(int index) async {
    var settings = await Settings.getInstance();
    var path = boardPaths.removeAt(index);
    save();
    File f = File('${settings.storagePath}/board_${path}.${BOARD_FILE_EXTENSION}');
    await f.delete();
  }

  Future<List<Board>> get boards async {
    var settings = await Settings.getInstance();
    List<Board> boards = [];
    for (String boardPath in boardPaths) {
      try {
        File file = File("${settings.storagePath}/board_$boardPath.$BOARD_FILE_EXTENSION");
        String s = await file.readAsString();
        boards.add(Board.fromJson(json.decode(s)));
      } on Exception catch (ex) {
        print(ex);
      }
    }
    return boards;
  }

  static Future<List<BoardFlow>> getFlows() async {
    var settings = await Settings.getInstance();
    var workingDir = Directory(settings.storagePath);
    List<FileSystemEntity> files = workingDir.listSync();
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

  Future<void> applyThemeToAll(BoardTheme theme) async {
    var boards = await this.boards;
    for (var board in boards) {
      board.theme = theme;
      await board.save();
    }
  }
}