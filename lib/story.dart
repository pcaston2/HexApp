import 'dart:convert';
import 'dart:io';

import 'package:flutter_guid/flutter_guid.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

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
    var cacheDir = await getApplicationDocumentsDirectory();
    File f = File('${cacheDir.path}/story_$guid.$STORY_FILE_EXTENSION');
    f.writeAsString(json.encode(toJson()));
  }

  Future<List<BoardFlow>> get flows async {
    Directory cacheDir = await getApplicationDocumentsDirectory();
    List<BoardFlow> flows = [];
    for (String flowPath in flowPaths) {
      try {
        File file = File("${cacheDir.path}/flow_$flowPath.$FLOW_FILE_EXTENSION");
        String s = await file.readAsString();
        flows.add(BoardFlow.fromJson(json.decode(s)));
      } on Exception catch (ex) {
        print(ex);
      }
    }
    return flows;
  }

  static Future<List<Story>> getStories() async {
    Directory cacheDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = cacheDir.listSync();
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
}