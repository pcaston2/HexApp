part of 'main.dart';

class HexPainter extends CustomPainter {
  //         <-- CustomPainter class

  GameState _gameState;
  HexPainter(this._gameState);

  @override
  void paint(Canvas canvas, Size size) {
    //canvas.clipRect(new Rect.fromLTWH(0, 0, size.width, size.height));
    Point center = Point(size.width / 2, size.height / 2);
    BoardTheme _theme = _gameState.board.theme;
    //paintFill(canvas, size, _theme);

    drawBoard(center, canvas, _theme);
    var entries = _gameState.board.flatten();
    entries.sort((a, b) => a.value.order.compareTo(b.value.order));
    for (var entry in entries) {
      var hex = entry.key;
      var piece = entry.value;
      if (piece is PathPiece) {
        drawPathPiece(hex, center, canvas, _theme);
      } else if (piece is StartPiece) {
        drawStartPiece(hex, center, canvas, _theme);
      } else if (piece is EndPiece) {
        drawEndPiece(hex, center, canvas, _theme);
      } else if (piece is DotRule) {
        drawDotRule(hex, center, canvas, piece, _theme);
      } else if (piece is SequenceRule) {
        drawColorRule(hex, center, canvas, piece, _theme);
      } else if (piece is EdgeRule) {
        drawEdgeRule(hex, center, canvas, piece, _theme);
      } else if (piece is CornerRule) {
        drawCornerRule(hex, center, canvas, piece, _theme);
      } else {
        drawErrorPiece(hex, center, piece, canvas);
      }
    }
    if (_gameState.board.mode == BoardMode.designer) {
      drawDesignSelection(center, canvas);
    } else {
      drawTrail(center, canvas, _theme);
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
      ..color = Colors.blueAccent.withAlpha(128)
      ..strokeWidth = 2
      ..blendMode = BlendMode.difference
      ..style = PaintingStyle.stroke;
    offsets.forEach((Offset offset) => canvas.drawCircle(offset, 5, paint));
    offsets.forEach((Offset offset) => canvas.drawCircle(offset, 10, paint));
  }

  void drawEndPiece(Hex hex, Point center, Canvas canvas, BoardTheme theme) {
    var offset = new Offset(center.x + hex.point.x + hex.midpoint.x,
        center.y + hex.point.y - hex.midpoint.y);
    final endPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          theme.path.darken(30).value,
          theme.path.darken(20).value,
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
          theme.path.brighten(20).value,
          theme.path.darken(20).value,
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

    //hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + hex.midpoint.x + p.x, hex.point.y + hex.midpoint.y - p.y)));
    canvas.drawPath(path, startPaint);
  }

  void drawColorRule(Hex hex, Point center, Canvas canvas, SequenceRule colorRule, BoardTheme theme) {

    var colorOffset = 0;
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
  }

  void drawDotRule(Hex hex, Point center, Canvas canvas, DotRule dotRule, BoardTheme theme) {
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
  }

  void drawEdgeRule(
      Hex hex, Point center, Canvas canvas, EdgeRule edgeRule, BoardTheme theme) {
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
    //canvas.drawCircle(Offset(center.x + hex.midpoint.x + hex.point.x, center.y - hex.midpoint.y + hex.point.y), 25, edgePaint);
    //Path path = Path();
    //path.addPolygon(pieceOffset, true);
    //canvas.drawPath(path, edgePaint);
  }

  void drawCornerRule(Hex hex, Point center, Canvas canvas, CornerRule cornerRule, BoardTheme theme) {
    final cornerPaint = Paint()
      ..color = theme.ruleColors[cornerRule.color]!.value
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (int i = 0;i<cornerRule.count; i++) {
      canvas.drawCircle(Offset(
        center.x + hex.point.x + hex.midpoint.x,
        center.y + hex.point.y - hex.midpoint.y,
      ), 9+i*5, cornerPaint);
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
    /*TextSpan span = new TextSpan(
        style: new TextStyle(color: Colors.blue[800]),
        text: "Selected Piece: ${_gameState.piece.name}");
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(5.0, 5.0));*/

    var fillRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // final fillPaint = Paint()..color = Colors.grey[200];
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fillPaint);

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

  void drawTrail(Point center, Canvas canvas, BoardTheme theme) {
    drawCurrentTrail(_gameState.board, center, canvas, theme);
    drawTrailStartPiece(_gameState.board, center, canvas, theme);
    drawTrailEndPiece(_gameState.board, center, canvas, theme);
  }

  void drawCurrentTrail(
      Board board, Point center, Canvas canvas, BoardTheme theme) {
    if (board.trail.length > 1) {
      final trailPaint = Paint()
        ..color = board.isFinished
            ? (board.isSuccess
                ? theme.trail.brighten(30).value
                : theme.trail.darken(10).value)
            : theme.trail.value
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      List<Offset> trailOffset = <Offset>[];
      board.trail.forEach((Hex h) => trailOffset.add(new Offset(
          center.x + h.point.x + h.midpoint.x,
          center.y + h.point.y - h.midpoint.y)));
      Path trailPath = Path();
      trailPath.addPolygon(trailOffset, false);
      canvas.drawPath(trailPath, trailPaint);
    }
  }

  void drawTrailEndPiece(
      Board board, Point center, Canvas canvas, BoardTheme theme) {
    if (board.hasEnded) {
      var offset = new Offset(
          center.x + board.tail!.point.x + board.tail!.midpoint.x,
          center.y + board.tail!.point.y - board.tail!.midpoint.y);
      final endPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            theme.trail.brighten(20).value,
            theme.trail.darken(10).value,
            board.isFinished
                ? (board.isSuccess
                    ? theme.trail.brighten(30).value
                    : theme.trail.darken(10).value)
                : theme.trail.value
          ],
        ).createShader(Rect.fromCircle(
          center: offset,
          radius: hexSize / 5.0,
        ));
      canvas.drawCircle(offset, hexSize / 3.5, endPaint);
    }
  }

  void drawTrailStartPiece(
      Board board, Point center, Canvas canvas, BoardTheme theme) {
    if (board.trail.length > 0) {
      final startPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            theme.trail.darken(20).value,
            theme.trail.darken(5).value,
            board.isFinished
                ? (board.isSuccess
                    ? theme.trail.brighten(30).value
                    : theme.trail.darken(10).value)
                : theme.trail.value
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
                vertex.y / 3.0,
            center.y +
                board.head.point.y -
                board.head.midpoint.y -
                vertex.x / 3.0));
      }
      Path path = Path();
      path.addPolygon(pieceOffset, true);

      //hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + hex.midpoint.x + p.x, hex.point.y + hex.midpoint.y - p.y)));
      canvas.drawPath(path, startPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }


}
