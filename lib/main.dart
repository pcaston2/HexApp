
import 'package:audioplayers/audioplayers.dart';
import 'package:hex_game/story.dart';
import 'package:hex_game/storyTile.dart';
import 'package:flutter/material.dart';
import 'dart:math';
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

bool developer = true;

void main() => runApp(MaterialApp(title: "Thex", home: StorySelection()));