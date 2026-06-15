import 'package:flutter/material.dart';
import 'story.dart';
import 'dart:math' as math;

class StoryGridTile extends StatelessWidget {
  final Story story;
  final bool completed;
  final int index;
  final VoidCallback onTap;

  const StoryGridTile({
    super.key,
    required this.story,
    required this.completed,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _StoryHexPainter(
                completed: completed,
                index: index + 1,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            story.name,
            style: TextStyle(
              color: Colors.black.withValues(alpha: completed ? 1.0 : 0.7),
              fontSize: 12,
              fontWeight: completed ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}

class _StoryHexPainter extends CustomPainter {
  final bool completed;
  final int index;

  _StoryHexPainter({
    required this.completed,
    required this.index,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.9;

    // Use a generic color for stories - Amber/Gold theme
    final Color primaryColor = Colors.amber.shade600;
    final Color borderColor = Colors.amber.shade300;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = i * math.pi / 3;
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    if (completed) {
      // Filled Hex
      final fillPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);
    } else {
      // Ghost Hex
      final ghostPaint = Paint()
        ..color = Colors.blueAccent.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawPath(path, ghostPaint);
    }

    // Draw index number
    final textSpan = TextSpan(
      text: '$index',
      style: TextStyle(
        color: completed ? Colors.blueAccent : Colors.blueAccent.withValues(alpha: 0.5),
        fontSize: radius * 0.8,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
