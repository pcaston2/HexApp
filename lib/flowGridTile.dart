import 'package:flutter/material.dart';
import 'boardFlow.dart';
import 'dart:math' as math;

class FlowGridTile extends StatelessWidget {
  final BoardFlow flow;
  final bool completed;
  final int index;
  final VoidCallback onTap;

  const FlowGridTile({
    super.key,
    required this.flow,
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
              painter: _FlowHexPainter(
                completed: completed,
                index: index + 1,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            flow.name,
            style: TextStyle(
              color: Colors.blueGrey.shade900.withOpacity(completed ? 1.0 : 0.7),
              fontSize: 12,
              fontWeight: completed ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FlowHexPainter extends CustomPainter {
  final bool completed;
  final int index;

  _FlowHexPainter({
    required this.completed,
    required this.index,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.9;

    // Royal Red theme for flows
    final Color primaryColor = Colors.red.shade800;
    final Color borderColor = Colors.red.shade300;

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
        ..color = primaryColor.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawPath(path, ghostPaint);
    }

    // Draw index number
    final textSpan = TextSpan(
      text: '$index',
      style: TextStyle(
        color: completed ? Colors.white : primaryColor.withOpacity(0.5),
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
