import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:archive/archive.dart';
import 'dart:math';
import 'settings.dart';
import 'story.dart';
import 'storyTile.dart';
import 'boardTheme.dart';
import 'flowTile.dart';
import 'pieceTile.dart';
import 'boardTile.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  settings = await Settings.getInstance();
  await loadStory("main");
  runApp(MaterialApp(title: "Thex", home: MainMenu()));
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