import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'boardTheme.dart';
import 'flowTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

void main() => runApp(MaterialApp(title: "Sise", home: FlowSelection()));




