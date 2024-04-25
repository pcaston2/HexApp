import 'package:flutter/material.dart';

import 'board.dart';

class BoardTile extends ListTile {
  final Board board;
  BoardTile({required this.board, required Widget title, required GestureTapCallback onTap}) : super(title: title, onTap: onTap);
}