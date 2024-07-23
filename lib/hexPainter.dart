part of 'main.dart';

class HexPainter extends CustomPainter {
  //         <-- CustomPainter class

  GameState _gameState;
  HexPainter(this._gameState);

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var center = Point(size.width / 2, size.height / 2);
    var _theme = _gameState.board.theme;
    var _animation = _gameState.boardAnimation;
    drawBoard(center, canvas, _theme);
    var entries = _gameState.board.flatten();
    entries.sort((a, b) => a.value.order.compareTo(b.value.order));
    double trailPulse = 0;
    double trailFade = 1;
    double errorPulse = 0;
    if (_gameState.board.hasEnded && !_gameState.board.isFinished) {
      trailPulse = _gameState.boardAnimation.pulse;
    }
    if (_gameState.board.isFinished && !_gameState.board.isSuccess) {
      trailFade = _gameState.boardAnimation.fade;
      if (trailFade > 0) {
        errorPulse = _gameState.boardAnimation.error;
      }
    }

    for (var entry in entries) {
      var hex = entry.key;
      var piece = entry.value;
      var errors = _gameState.board.errors.where((BoardValidationError e) => e.hex == hex && e.piece.runtimeType == piece.runtimeType).toList();

      if (piece is PathPiece) {
        drawPathPiece(hex, center, canvas, _theme);
      } else if (piece is BreakPiece) {
        drawBreakPiece(hex, center, canvas, _theme);
      } else if (piece is StartPiece) {
        drawStartPiece(hex, center, canvas, _theme);
      } else if (piece is EndPiece) {
        drawEndPiece(hex, center, canvas, _theme);
      } else if (piece is DotRule) {
        drawDotRule(hex, center, canvas, piece, _theme, errorPulse, errors);
      } else if (piece is SequenceRule) {
        drawColorRule(hex, center, canvas, piece, _theme, errorPulse, errors);
      } else if (piece is EdgeRule) {
        drawEdgeRule(hex, center, canvas, piece, _theme, errorPulse, errors);
      } else if (piece is CornerRule) {
        drawCornerRule(hex, center, canvas, piece, _theme, errorPulse, errors);
      } else {
        drawErrorPiece(hex, center, piece, canvas);
      }
    }
    if (_gameState.board.mode == BoardMode.designer) {
      drawDesignSelection(center, canvas);
    } else {
      drawTrail(center, canvas, _theme, trailPulse, trailFade);
    }
    if (_gameState.board.mode == BoardMode.play) {
      for (var entry in entries) {
        var hex = entry.key;
        var piece = entry.value;
        if (piece is StartPiece) {
          if (!_gameState.board.hasStarted) {
            drawStartAnimation(hex, center, canvas, _theme, _animation.beckon);
          }
        } else if (piece is EndPiece) {
          if (!_gameState.board.hasEnded && _gameState.board.hasStarted) {
            drawEndAnimation(hex, center, canvas, _theme, _animation.beckon);
          }
        }
      }
      drawCrosshair(canvas, center, _gameState.board.crosshair);
    }


    //ViewFocalpoint(center, canvas, localFocalStart);
  }

  void drawDesignSelection(Point center, Canvas canvas) {
    List<Offset> offsets = <Offset>[];
    for (var vertex in _gameState.pointer.vertexOffsets) {
      offsets.add(new Offset(center.x + _gameState.pointer.point.x + vertex.x,
          center.y + _gameState.pointer.point.y - vertex.y));
    }
    final paint = Paint()
      ..color = Colors.blueAccent.withAlpha(64)
      ..strokeWidth = offsets.length == 1 ? 35 : (offsets.length == 2 ? 26 : 15)
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.difference
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5.0);
    //offsets.forEach((Offset offset) => canvas.drawCircle(offset, 5, paint));
    //offsets.forEach((Offset offset) => canvas.drawCircle(offset, 10, paint));
    if (offsets.length == 1) {
      canvas.drawPoints(PointMode.points,offsets,paint);
    } else if (offsets.length == 2) {
      canvas.drawPoints(PointMode.lines, offsets, paint);
    } else {
      var poly = [...offsets];
      poly.add(poly.first);
      var path = Path();
      path.moveTo(poly.first.dx, poly.first.dy);
      poly.skip(1).forEach((e) => path.lineTo(e.dx,e.dy));
      canvas.drawPath(path, paint);
      //canvas.drawPoints(PointMode.polygon, poly, paint);
    }
  }

  void drawEndPiece(Hex hex, Point center, Canvas canvas, BoardTheme theme) {
    var offset = new Offset(center.x + hex.point.x + hex.midpoint.x,
        center.y + hex.point.y - hex.midpoint.y);
    final endPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          theme.path.darken(15).value,
          theme.path.darken(5).value,
          theme.path.value,
        ],
      ).createShader(Rect.fromCircle(
        center: offset,
        radius: hexSize / 5.0,
      ));
    canvas.drawCircle(offset, hexSize / 4.0, endPaint);
  }

  void drawErrorPiece(Hex hex, Point center, Piece piece, Canvas canvas) {
    TextSpan errorSpan =
        new TextSpan(style: new TextStyle(color: Colors.red), text: piece.name);
    TextPainter errorPainter = new TextPainter(
        text: errorSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    errorPainter.layout();
    Offset offset = new Offset(center.x + hex.point.x + hex.midpoint.x,
        center.y + hex.point.y - hex.midpoint.y);
    errorPainter.paint(canvas, offset);
  }

  void drawStartPiece(Hex hex, Point center, Canvas canvas, BoardTheme theme) {
    final startPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          theme.path.brighten(15).value,
          theme.path.brighten(5).value,
          theme.path.value,
        ],
      ).createShader(Rect.fromCircle(
        center: new Offset(center.x + hex.point.x + hex.midpoint.x,
            center.y + hex.point.y - hex.midpoint.y),
        radius: hexSize / 4.0,
      ));
    List<Offset> pieceOffset = <Offset>[];
    for (var vertex in Hex.origin().vertexOffsets) {
      pieceOffset.add(new Offset(
          center.x + hex.point.x + hex.midpoint.x + vertex.y / 3.5,
          center.y + hex.point.y - hex.midpoint.y - vertex.x / 3.5));
    }
    Path path = Path();
    path.addPolygon(pieceOffset, true);
    canvas.drawPath(path, startPaint);
  }

  void drawColorRule(Hex hex, Point center, Canvas canvas, SequenceRule colorRule, BoardTheme theme, double errorPulse, List<BoardValidationError> errors) {
    var colorOffset = 0;
    if (colorRule.colors.isEmpty) {
      drawErrorPiece(hex, center, colorRule, canvas);
    }
    for (var color in colorRule.colors) {
      var colorPaint = Paint()
      ..color = theme.ruleColors[color]!.value
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
      for (var vertex in Hex
          .origin()
          .vertexOffsets) {
        Point direction = vertex / 6.0;
        Point rotationA = direction.rotate(120);
        Point rotationB = direction.rotate(-120);
        var corner = new Offset(
            center.x + hex.point.x + hex.midpoint.x + vertex.x * 0.75 * (1 - colorOffset*0.08),
            center.y + hex.point.y - hex.midpoint.y - vertex.y * 0.75 * (1 - colorOffset*0.08));
        canvas.drawLine(
            corner, corner + Offset(rotationA.x, -rotationA.y), colorPaint);
        canvas.drawLine(
            corner, corner + Offset(rotationB.x, -rotationB.y), colorPaint);
      }
      colorOffset++;
    }

    if (errorPulse != 0 && errors.isNotEmpty) {
      final errorPaint = Paint()
        ..color = (errorPulse < 0 ? Colors.black : Colors.red).withOpacity(errorPulse.abs())
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      var colorOffset = 0;
      for (var color in colorRule.colors) {
        if (
        errors.any((e) => e.runtimeType == BoardValidationError) ||
        errors.whereType<BoardValidationColorError>().any((e) => e.color == color)
        ) {
          for (var vertex in Hex
              .origin()
              .vertexOffsets) {
            Point direction = vertex / 6.0;
            Point rotationA = direction.rotate(120);
            Point rotationB = direction.rotate(-120);
            var corner = new Offset(
                center.x + hex.point.x + hex.midpoint.x +
                    vertex.x * 0.75 * (1 - colorOffset * 0.08),
                center.y + hex.point.y - hex.midpoint.y -
                    vertex.y * 0.75 * (1 - colorOffset * 0.08));
            canvas.drawLine(
                corner, corner + Offset(rotationA.x, -rotationA.y), errorPaint);
            canvas.drawLine(
                corner, corner + Offset(rotationB.x, -rotationB.y), errorPaint);
          }
          colorOffset++;
        }
      }
    }
  }

  void drawDotRule(Hex hex, Point center, Canvas canvas, DotRule dotRule, BoardTheme theme, double errorPulse, List<BoardValidationError> errors) {
    final startPaint = Paint()
      ..color = theme.ruleColors[dotRule.color]!.value
      ..style = PaintingStyle.fill;
    List<Offset> pieceOffset = <Offset>[];
    for (var vertex in Hex.origin().vertexOffsets) {
      pieceOffset.add(new Offset(
          center.x + hex.point.x + hex.midpoint.x + vertex.x / 12,
          center.y + hex.point.y - hex.midpoint.y - vertex.y / 12));
    }
    Path path = Path();
    path.addPolygon(pieceOffset, true);

    //hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + hex.midpoint.x + p.x, hex.point.y + hex.midpoint.y - p.y)));
    canvas.drawPath(path, startPaint);

    if (errorPulse != 0 && errors.isNotEmpty) {
      final errorPaint = Paint()
          ..color = (errorPulse < 0 ? Colors.black : Colors.red).withOpacity(errorPulse.abs());
          canvas.drawPath(path, errorPaint);
    }
  }

  void drawEdgeRule(
      Hex hex, Point center, Canvas canvas, EdgeRule edgeRule, BoardTheme theme, double errorPulse, List<BoardValidationError> errors) {
    final edgePaint = Paint()
      ..color = theme.ruleColors[edgeRule.color]!.value
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    var m = hex.midpoint.rotate(90);
    if (edgeRule.count == 1) {
      canvas.drawLine(
          Offset(center.x + hex.point.x + m.x * 0.6,
              center.y + hex.point.y - m.y * 0.6),
          Offset(center.x + hex.point.x - m.x * 0.6,
              center.y + hex.point.y + m.y * 0.6),
          edgePaint);
    } else {
      var centerOffset = hex.midpoint / 10;
      canvas.drawLine(
          Offset(center.x + hex.point.x + m.x * 0.6 + centerOffset.x,
              center.y + hex.point.y - m.y * 0.6 - centerOffset.y),
          Offset(center.x + hex.point.x - m.x * 0.6 + centerOffset.x,
              center.y + hex.point.y + m.y * 0.6 - centerOffset.y),
          edgePaint);

      canvas.drawLine(
          Offset(center.x + hex.point.x + m.x * 0.6 - centerOffset.x,
              center.y + hex.point.y - m.y * 0.6 + centerOffset.y),
          Offset(center.x + hex.point.x - m.x * 0.6 - centerOffset.x,
              center.y + hex.point.y + m.y * 0.6 + centerOffset.y),
          edgePaint);
    }
    if (errorPulse != 0 && errors.isNotEmpty) {
      final errorPaint = Paint()
        ..color = (errorPulse < 0 ? Colors.black : Colors.red).withOpacity(errorPulse.abs())
        ..strokeWidth = 3;
      var m = hex.midpoint.rotate(90);
      if (edgeRule.count == 1) {
        canvas.drawLine(
            Offset(center.x + hex.point.x + m.x * 0.6,
                center.y + hex.point.y - m.y * 0.6),
            Offset(center.x + hex.point.x - m.x * 0.6,
                center.y + hex.point.y + m.y * 0.6),
            errorPaint);
      } else {
        var centerOffset = hex.midpoint / 10;
        canvas.drawLine(
            Offset(center.x + hex.point.x + m.x * 0.6 + centerOffset.x,
                center.y + hex.point.y - m.y * 0.6 - centerOffset.y),
            Offset(center.x + hex.point.x - m.x * 0.6 + centerOffset.x,
                center.y + hex.point.y + m.y * 0.6 - centerOffset.y),
            errorPaint);

        canvas.drawLine(
            Offset(center.x + hex.point.x + m.x * 0.6 - centerOffset.x,
                center.y + hex.point.y - m.y * 0.6 + centerOffset.y),
            Offset(center.x + hex.point.x - m.x * 0.6 - centerOffset.x,
                center.y + hex.point.y + m.y * 0.6 + centerOffset.y),
            errorPaint);
      }
    }
  }

  void drawCornerRule(Hex hex, Point center, Canvas canvas, CornerRule cornerRule, BoardTheme theme, double errorPulse, List<BoardValidationError> errors) {
    final cornerPaint = Paint()
      ..color = theme.ruleColors[cornerRule.color]!.value
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 0;i<cornerRule.count; i++) {
      canvas.drawCircle(Offset(
        center.x + hex.point.x + hex.midpoint.x,
        center.y + hex.point.y - hex.midpoint.y,
      ), 11-i*4, cornerPaint);
    }

    if (errorPulse != 0 && errors.isNotEmpty) {
      final errorPaint = Paint()
        ..color = (errorPulse < 0 ? Colors.black : Colors.red).withOpacity(
            errorPulse.abs())
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < cornerRule.count; i++) {
        canvas.drawCircle(Offset(
          center.x + hex.point.x + hex.midpoint.x,
          center.y + hex.point.y - hex.midpoint.y,
        ), 11 - i * 4, errorPaint);
      }
    }
  }

  void drawPathPiece(Hex hex, Point center, Canvas canvas, BoardTheme theme) {
    final pathPaint = Paint()
      ..color = theme.path.value
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    List<Offset> pieceOffset = <Offset>[];
    hex.vertexOffsets.forEach((Point p) => pieceOffset.add(new Offset(
        center.x + hex.point.x + p.x, center.y + hex.point.y - p.y)));
    canvas.drawLine(pieceOffset[0], pieceOffset[1], pathPaint);
  }

  void drawBreakPiece(Hex hex, Point center, Canvas canvas, BoardTheme theme) {
    final pathPaint = Paint()
      ..color = theme.path.value
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.butt;
    List<Offset> pieceOffset = <Offset>[];
    hex.vertexOffsets.forEach((Point p) => pieceOffset.add(new Offset(
        center.x + hex.point.x + p.x, center.y + hex.point.y - p.y)));
    var scalar = (pieceOffset[0] - pieceOffset[1]) * 0.42;
    canvas.drawLine(pieceOffset[0], pieceOffset[0] - scalar, pathPaint);
    canvas.drawLine(pieceOffset[1], pieceOffset[1] + scalar, pathPaint);
  }

  void drawBoard(Point center, Canvas canvas, BoardTheme theme) {
    List<Offset> boardOffset = <Offset>[];
    var vertexes = vertex.values;
    vertexes.forEach((Point p) => boardOffset.add(Offset(
        center.x + p.y * 2 * _gameState.board.size,
        center.y + p.x * 2 * (_gameState.board.size))));
    var boardPath = Path();
    boardPath.addPolygon(boardOffset, true);
    final boardFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          theme.foreground.brighten(30).value,
          theme.foreground.darken(30).value,
        ],
      ).createShader(Rect.fromCircle(
        center: new Offset(center.x, center.y),
        radius: hexSize * 2 * _gameState.board.size,
      ));
    canvas.drawPath(boardPath, boardFillPaint);
    final boardEdgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = 15
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0)
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.border.value,
          theme.border.brighten(40).value,
          theme.border.value,
        ],
      ).createShader(Rect.fromCircle(
        center: new Offset(center.x, center.y),
        radius: hexSize + hexSize * 2 * (_gameState.board.size - 1),
      ));
    canvas.drawPath(boardPath, boardEdgePaint);
  }

  void paintFill(Canvas canvas, Size size, BoardTheme theme) {
    var fillRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.background.brighten(5).value,
            theme.background.darken(5).value,
            theme.background.brighten(5).value,
          ],
          stops: [
            0.4,
            0.5,
            0.6,
          ]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(fillRect, fillPaint);
  }

  void drawTrail(Point center, Canvas canvas, BoardTheme theme, double trailPulse, double trailFade) {
    double tips = max(0,trailFade-(1-trailFade));
    double mid = min(1,trailFade * 2);
    drawCurrentTrail(_gameState.board, center, canvas, theme, trailPulse, mid);
    if (!_gameState.board.hasEnded) {
      drawIncrementalTrail(_gameState.board, center, canvas);
    }
    drawTrailStartPiece(_gameState.board, center, canvas, theme, trailPulse, tips);
    drawTrailEndPiece(_gameState.board, center, canvas, theme, trailPulse, tips);
  }

  void drawCurrentTrail(Board board, Point center, Canvas canvas,
      BoardTheme theme, double trailPulse, double trailFade) {
    if (board.trail.length > 1) {
      final trailPaint = Paint()
        ..color = (board.isFinished
            ? (board.isSuccess
                ? theme.trail.brighten(20).value
                : theme.trail.darken(10).value)
            : theme.trail.brighten((trailPulse * 5).round()).value).withOpacity(trailFade)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0)
        ..strokeCap = StrokeCap.round;
      List<Offset> trailOffset = <Offset>[];
      board.trail.forEach((Hex h) => trailOffset.add(new Offset(
          center.x + h.point.x + h.midpoint.x,
          center.y + h.point.y - h.midpoint.y)));
      if ((board.next != null) && board.trail.contains(board.next) && !board.hasEnded) {
        trailOffset.removeLast();
      }
      Path trailPath = Path();
      trailPath.addPolygon(trailOffset, false);
      canvas.drawPath(trailPath, trailPaint);
    }
  }

  void drawIncrementalTrail(Board board, Point center, Canvas canvas) {
    var next = board.next;
    if (next != null) {
      final incrementalPaint = Paint()
        ..color = (board.isFinished
            ? (board.isSuccess
            ? board.theme.trail.brighten(20).value
            : board.theme.trail.darken(10).value)
            : board.theme.trail.value)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);

      var current = board.tail!.localPoint;
      var to = next.localPoint;
      var distance = (board.crosshair!-current).magnitude;
      var maxDistance = (to - current).magnitude;
      if (distance > maxDistance) {
        distance = maxDistance;
      }
      var scaleTo = (to-current).unitVector * distance + current;

      if (board.trail.contains(next)) {
        var previous = board.trail.reversed.skip(1).first.localPoint;
        canvas.drawLine(Offset(previous.x + center.x, previous.y + center.y),
            Offset(scaleTo.x + center.x, scaleTo.y + center.y),
            incrementalPaint);
      } else {
        canvas.drawLine(Offset(current.x + center.x, current.y + center.y),
            Offset(scaleTo.x + center.x, scaleTo.y + center.y),
            incrementalPaint);
      }
    }
  }

  void drawTrailEndPiece(
      Board board, Point center, Canvas canvas, BoardTheme theme, double trailPulse, double trailFade) {
    if (board.hasEnded) {
      var offset = new Offset(
          center.x + board.tail!.point.x + board.tail!.midpoint.x,
          center.y + board.tail!.point.y - board.tail!.midpoint.y);
      final endPaint = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0)
        ..shader = RadialGradient(
          colors: [
            theme.trail.brighten(5).value.withOpacity(trailFade),
            theme.trail.darken(2).value.withOpacity(trailFade),
            (board.isFinished
                ? (board.isSuccess
                    ? theme.trail.brighten(30).value
                    : theme.trail.darken(10).value)
                : theme.trail.brighten((trailPulse * 5).round()).value).withOpacity(trailFade)
          ],
        ).createShader(Rect.fromCircle(
          center: offset,
          radius: hexSize / 5.0,
        ));
      canvas.drawCircle(offset, hexSize / 4.0, endPaint);
    }
  }

  void drawTrailStartPiece(
      Board board, Point center, Canvas canvas, BoardTheme theme, double trailPulse, double trailFade) {
    if (board.trail.length > 0) {
      final startPaint = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0)
        ..shader = RadialGradient(
          colors: [
            theme.trail.darken(5).value.withOpacity(trailFade),
            theme.trail.darken(2).value.withOpacity(trailFade),
            (board.isFinished
              ? (board.isSuccess
                    ? theme.trail.brighten(30).value
                    : theme.trail.darken(10).value)
                : theme.trail.brighten((trailPulse * 5).round()).value).withOpacity(trailFade)
          ],
        ).createShader(Rect.fromCircle(
          center: new Offset(
              center.x + board.head.point.x + board.head.midpoint.x,
              center.y + board.head.point.y - board.head.midpoint.y),
          radius: hexSize / 4.0,
        ));
      List<Offset> pieceOffset = <Offset>[];
      for (var vertex in Hex.origin().vertexOffsets) {
        pieceOffset.add(new Offset(
            center.x +
                board.head.point.x +
                board.head.midpoint.x +
                vertex.y / 3.5,
            center.y +
                board.head.point.y -
                board.head.midpoint.y -
                vertex.x / 3.5));
      }
      Path path = Path();
      path.addPolygon(pieceOffset, true);

      //hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + hex.midpoint.x + p.x, hex.point.y + hex.midpoint.y - p.y)));
      canvas.drawPath(path, startPaint);
    }
  }

  void drawStartAnimation(Hex hex, Point center, Canvas canvas, BoardTheme theme, double beckon) {
    final startPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(max(1-beckon*2,0));
    List<Offset> pieceOffset = <Offset>[];
    for (var vertex in Hex.origin().vertexOffsets) {
      pieceOffset.add(new Offset(
          center.x + hex.point.x + hex.midpoint.x + vertex.y / 3.5 * (1+beckon*5),
          center.y + hex.point.y - hex.midpoint.y - vertex.x / 3.5 * (1+beckon*5)));
    }
    Path path = Path();
    path.addPolygon(pieceOffset, true);
    canvas.drawPath(path, startPaint);
  }

  void drawEndAnimation(Hex hex, Point center, Canvas canvas, BoardTheme theme, double beckon) {
    var offset = new Offset(center.x + hex.point.x + hex.midpoint.x,
        center.y + hex.point.y - hex.midpoint.y);
    final endPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(max(1-beckon*2,0));


    canvas.drawCircle(offset, hexSize / 4.0 * (1+beckon*5), endPaint);
  }

  void drawCrosshair(Canvas canvas, Point center, Point? crosshair) {
    if (crosshair != null) {
      final cornerPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(center.x + crosshair.x,
        center.y + crosshair.y,
      ), 8, cornerPaint);
    }
  }





}
