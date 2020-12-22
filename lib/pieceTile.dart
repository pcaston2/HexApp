import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'piece.dart';

class PieceTile extends ListTile {
  Piece piece;
  PieceTile(this.piece, GestureTapCallback onTap) : super(title: new Text(piece.name), onTap: (() { onTap.call(); }));
}