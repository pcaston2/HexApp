import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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
  runApp(MaterialApp(title: "Thex", home: MainMenu()));
}