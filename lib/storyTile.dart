import 'package:flutter/material.dart';

import 'story.dart';

class StoryTile extends ListTile {
  final Story story;
  StoryTile({required this.story, required Widget title, required GestureTapCallback onTap}) : super(
    title: title,
    onTap: onTap,
    leading: Visibility(child:
      Icon(
        Icons.check_rounded,
        color: Colors.greenAccent,
        size: 24.0,
        semanticLabel: "Completed"
      ),
      visible: story.completed,
    )
  );
}