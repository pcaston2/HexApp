import 'package:flutter/material.dart';

import 'boardFlow.dart';

class FlowTile extends ListTile {
  final BoardFlow flow;
  FlowTile({this.flow, Widget title, GestureTapCallback onTap}) : super(title: title, onTap: onTap);
}