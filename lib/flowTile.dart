import 'package:flutter/material.dart';

import 'boardFlow.dart';

class FlowTile extends ListTile {
  final BoardFlow flow;
  FlowTile({required this.flow, required Widget title, required GestureTapCallback onTap}) : super(title: title, onTap: onTap);
}