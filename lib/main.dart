import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'boardTheme.dart';
import 'flowTile.dart';

/// Flutter code sample for RadioListTile

// ![RadioListTile sample](https://flutter.github.io/assets-for-api-docs/assets/material/radio_list_tile.png)
//
// This widget shows a pair of radio buttons that control the `_character`
// field. The field is of the type `SingingCharacter`, an enum.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'pieceTile.dart';
import 'boardTile.dart';
import 'boardFlow.dart';
import 'piece.dart';
import 'board.dart';

import 'hex.dart';


part 'hexPainter.dart';
part 'sound.dart';
part 'boardView.dart';
part 'flowSelection.dart';
part 'boardSelection.dart';

Offset focalStart = Offset.zero;

void main() => runApp(MaterialApp(title: "Hex Puzzle Game", home: FlowSelection()));




