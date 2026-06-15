import 'package:flutter/material.dart';
import 'board.dart';
import 'boardTheme.dart';
import 'dart:math' as math;

class BoardGridTile extends StatelessWidget {
  final Board board;
  final bool completed;
  final int index;
  final VoidCallback onTap;

  const BoardGridTile({
    super.key,
    required this.board,
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
              painter: _HexTilePainter(
                theme: board.theme,
                completed: completed,
                index: index + 1,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            board.name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: completed ? 1.0 : 0.7),
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

class _HexTilePainter extends CustomPainter {
  final BoardTheme theme;
  final bool completed;
  final int index;

  _HexTilePainter({
    required this.theme,
    required this.completed,
    required this.index,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.9;

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
        ..color = theme.foreground.value
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = theme.border.value
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);
    } else {
      // Ghost Hex
      final ghostPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawPath(path, ghostPaint);
    }

    // Draw index number
    final textSpan = TextSpan(
      text: '$index',
      style: TextStyle(
        color: completed ? Colors.white : Colors.white.withValues(alpha: 0.5),
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
