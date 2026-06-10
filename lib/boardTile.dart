import 'package:flutter/material.dart';

import 'board.dart';

class BoardTile extends ListTile {
  final Board board;
  final bool completed;
  BoardTile({required this.board, this.completed = false, required Widget title, required GestureTapCallback onTap}) :
        super(title: title,
          leading: Visibility(
            child: Icon(
              Icons.check_rounded,
              color: Colors.greenAccent,
              size: 24.0,
              semanticLabel: 'Completed',
            ),
            visible: completed
          ),
          onTap: onTap);
}