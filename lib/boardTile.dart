import 'package:flutter/material.dart';

import 'board.dart';

class BoardTile extends ListTile {
  final Board board;
  BoardTile({this.board, Widget title, GestureTapCallback onTap}) : super(title: title, onTap: onTap);
}