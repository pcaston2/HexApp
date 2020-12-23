import 'package:flutter/material.dart';
import 'piece.dart';

class PieceTile extends ListTile {
  final Piece piece;
  PieceTile(this.piece, GestureTapCallback onTap) : super(title: new Text(piece.name), onTap: (() { onTap.call(); }));
}