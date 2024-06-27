import 'dart:convert';
import 'dart:io';

import 'package:flutter_guid/flutter_guid.dart';
import 'settings.dart';
import 'package:json_annotation/json_annotation.dart';

import 'boardFlow.dart';

part 'story.g.dart';

const String STORY_FILE_EXTENSION = "jhexstory";

@JsonSerializable()
class Story {
  String name;
  late Guid _guid;

  late bool completed;

  String get guid {
    return _guid.value;
  }

  set guid(String value) {
    _guid = new Guid(value);
  }

  List<String> flowPaths = [];

  Story() : this.named("Untitled");

  Story.named(this.name) {
    _guid = Guid.newGuid;
    completed = false;
  }

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);

  String toString() {
    return name;
  }

  static Future<Story> createStory(String storyName) async {
    Story story = new Story.named(storyName);
    await story.save();
    return story;
  }

  Future<void> save() async {
    var settings = await Settings.getInstance();
    File f = File('${settings.storagePath}/story_$guid.$STORY_FILE_EXTENSION');
    await f.writeAsString(json.encode(toJson()));
  }

  Future<List<BoardFlow>> get flows async {
    var settings = await Settings.getInstance();
    List<BoardFlow> flows = [];
    for (String flowPath in flowPaths) {
      try {
        var flow = await loadFlow("${settings.storagePath}/flow_$flowPath.$FLOW_FILE_EXTENSION");
        flows.add(flow);
      } on Exception catch (ex) {
        print(ex);
      }
    }
    return flows;
  }

  Future<BoardFlow> loadFlow(String filename) async {
    File file = File(filename);
    String s = await file.readAsString();
    return BoardFlow.fromJson(json.decode(s));
  }

  static Future<List<Story>> getStories() async {
    var settings = await Settings.getInstance();
    var workingDir = Directory(settings.storagePath);
    List<FileSystemEntity> files = workingDir.listSync();
    var storyFiles = files.where((FileSystemEntity entity) => entity.path.contains(".$STORY_FILE_EXTENSION"));
    List<Story> stories = [];
    for (FileSystemEntity fse in storyFiles) {
      try {
        File file = File(fse.path);
        String s = await file.readAsString();
        stories.add(Story.fromJson(json.decode(s)));
      } on Exception catch (ex) {
        print(ex);
      }
    }
    return stories;
  }

  Future<void> deleteAt(int index) async {
    var settings = await Settings.getInstance();
    var flowToDelete = await loadFlow("${settings.storagePath}/flow_${flowPaths[index]}.$FLOW_FILE_EXTENSION");
    while (flowToDelete.boardPaths.isNotEmpty) {
      await flowToDelete.deleteAt(0);
    }
    var path = flowPaths.removeAt(index);
    await save();
    File f = File('${settings.storagePath}/flow_${path}.${FLOW_FILE_EXTENSION}');
    await f.delete();
  }
}