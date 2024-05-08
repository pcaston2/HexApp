import 'package:flutter/material.dart';

import 'board.dart';

class BoardTile extends ListTile {
  final Board board;
  BoardTile({required this.board, required Widget title, required GestureTapCallback onTap}) :
        super(title: title,
          leading: Visibility(
            child: Icon(
              Icons.check_rounded,
              color: Colors.greenAccent,
              size: 24.0,
              semanticLabel: 'Completed',
            ),
            visible: board.completed
          ),
          onTap: onTap);
}