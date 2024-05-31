import 'package:flutter/material.dart';

import 'boardFlow.dart';

class FlowTile extends ListTile {
  final BoardFlow flow;
  FlowTile({required this.flow, required Widget title, required GestureTapCallback onTap}) : super(
      title: title,
      onTap: onTap,
      leading: Visibility(child:
        Icon(
            Icons.check_rounded,
            color: Colors.greenAccent,
            size: 24.0,
            semanticLabel: "Completed",
        ),
        visible: flow.completed,
      )
  );
}