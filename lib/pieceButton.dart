
import 'package:flutter/material.dart';

import 'piece.dart';

Widget icon = Icon(Icons.abc);
Map<String, IconData> iconMap = {
  "Path": Icons.show_chart_rounded,
  "Erase": Icons.clear_rounded,
  "Start": Icons.flag_circle_rounded,
  "End": Icons.flag_circle_rounded,
  "Dot": Icons.scatter_plot_rounded,
  "Sequence": Icons.arrow_forward_ios_rounded,
  "Edge": Icons.remove_rounded,
  "Corner": Icons.radio_button_unchecked,
  "Break Path": Icons.merge_type_rounded,
};

class PieceButton extends IconButton {
  final Piece piece;
  PieceButton(this.piece, Function()? onPressed, Color color) :
        super(
          onPressed: onPressed,
          tooltip: piece.name,
          icon: Icon(iconMap[piece.name] ?? Icons.error_rounded,
              color:
                (piece.name == "Start" ? Colors.green :
                  (piece.name == "End" ? Colors.red :
                    (piece is ColoredRule || piece.name == "Sequence" ? color : Colors.black))))) {

  }
}