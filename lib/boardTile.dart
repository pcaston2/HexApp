import 'package:flutter/material.dart';

import 'board.dart';

class BoardTile extends ListTile {
  final Board board;
  BoardTile({Key key, this.board, Widget title, GestureTapCallback onTap}) : super(key: key, title: title, onTap: onTap);
}