import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter_rating_stars/flutter_rating_stars.dart';
//import 'package:gameanalytics_sdk/gameanalytics.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hex_game/pieceButton.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:math';
import 'settings.dart';
import 'story.dart';
import 'storyTile.dart';
import 'storyGridTile.dart';
import 'boardTheme.dart';
import 'flowTile.dart';
import 'flowGridTile.dart';
import 'pieceTile.dart';
import 'boardTile.dart';
import 'boardGridTile.dart';
import 'boardFlow.dart';
import 'colorTile.dart';
import 'piece.dart';
import 'board.dart';
import 'hex.dart';
part 'hexPainter.dart';
part 'sound.dart';
part 'boardView.dart';
part 'flowSelection.dart';
part 'boardSelection.dart';
part 'storySelection.dart';
part 'boardAnimation.dart';
part 'mainMenu.dart';

late Settings settings;
late SoundPlayer soundPlayer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  settings = await Settings.getInstance();
  soundPlayer = await SoundPlayer.create();
  await loadStories();
  //GameAnalytics.configureAutoDetectAppVersion(true);
  //GameAnalytics.initialize("4dca4a4b41d0772a7b8d4076268b7a7f", "7250dba7e4f6ecb8634fae21b6bda7365de9c400");
  //GameAnalytics.setEnabledInfoLog(true);
  //GameAnalytics.setEnabledVerboseLog(true);
  runApp(MaterialApp(
      title: "Thex",
      home: MainMenu(),
      debugShowCheckedModeBanner: false,
  ));
}

Future<void> loadStories() async {
  await loadStory("main");
}

Future<void> loadStory(String storyName) async {
  var settings = await Settings.getInstance();
  if (!settings.getLoaded(storyName)) {
    var zipPath = 'assets/$storyName.zip';
    final bytes = await rootBundle.load(zipPath);
    var byteList = Uint8List.sublistView(bytes);
    final archive = ZipDecoder().decodeBytes(byteList);
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        var path = '${settings.storagePath}/' + filename;
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        print('surprise! a directory!');
      }
    }
    settings.setLoaded(storyName);
  }
}
