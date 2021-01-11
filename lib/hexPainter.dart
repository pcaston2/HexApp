part of 'main.dart';


class HexPainter extends CustomPainter {
  //         <-- CustomPainter class

  GameState _gameState;
  HexPainter(this._gameState);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(new Rect.fromLTWH(0, 0, screenSize.dx, screenSize.dy));
    Point center = Point(screenCenter.dx, screenCenter.dy);

    paintFill(canvas, size);

    drawBoard(center, canvas);

    var entries = _gameState.board.flatten();
    entries.sort((a, b) => a.value.order.compareTo(b.value.order));
    for (var entry in entries) {
      var hex = entry.key;
      var piece = entry.value;
      if (piece is PathPiece) {
        drawPathPiece(hex, center, canvas);
      } else if (piece is StartPiece) {
        drawStartPiece(hex, center, canvas);
      } else if (piece is EndPiece) {
        drawEndPiece(hex, center, canvas);
      } else if (piece is DotRulePiece) {
        drawDotRulePiece(hex, center, canvas);
      } else if (piece is BreakRulePiece) {
        drawBreakRulePiece(hex, center, canvas);
      } else if (piece is EdgeRulePiece) {
        drawEdgeRulePiece(hex, center, canvas);
      } else {
        drawErrorPiece(hex, center, piece, canvas);
      }
    }
    if (_gameState.board.mode == BoardMode.designer) {
      drawDesignSelection(center, canvas);
    } else {
      drawTrail(center, canvas);
    }
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

  void drawEndPiece(Hex hex, Point center, Canvas canvas) {
    var offset = new Offset(center.x + hex.point.x + hex.midpoint.x,
        center.y + hex.point.y - hex.midpoint.y);
    final endPaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.blueGrey[100],
          Colors.blueGrey[600],
          Colors.blueGrey,
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

  void drawStartPiece(Hex hex, Point center, Canvas canvas) {
    final startPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.blueGrey[800],
          Colors.blueGrey[700],
          Colors.blueGrey,
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

  void drawBreakRulePiece(Hex hex, Point center, Canvas canvas) {
    final breakPaint = Paint()
      ..color = Colors.grey[800]
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
    //..blendMode = BlendMode.hardLight
      ..style = PaintingStyle.stroke;
    // ..shader = RadialGradient(
    //   colors: [
    //     Colors.black.withAlpha(0),
    //     Colors.black.withAlpha(200),
    //     Colors.black.withAlpha(0),
    //   ],
    //   stops: [
    //     0.7,
    //     0.75,
    //     0.8
    //   ]
    // ).createShader(Rect.fromCircle(
    //   center: new Offset(center.x + hex.point.x, center.y + hex.point.y),
    //   radius: hexSize,
    // ));
    List<Offset> pieceOffset = <Offset>[];
    for (var vertex in Hex.origin().vertexOffsets) {
      pieceOffset.add(new Offset(
          center.x + hex.point.x + hex.midpoint.x + vertex.x * 0.85,
          center.y + hex.point.y - hex.midpoint.y - vertex.y * 0.85));
    }
    pieceOffset.add(pieceOffset.first);
    pieceOffset.removeAt(0);
    Path path = Path();
    path.addPolygon(pieceOffset, true);
    //canvas.drawPoints(PointMode.lines, pieceOffset, breakPaint);
    //hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + hex.midpoint.x + p.x, hex.point.y + hex.midpoint.y - p.y)));
    canvas.drawPath(path, breakPaint);
  }

  void drawDotRulePiece(Hex hex, Point center, Canvas canvas) {
    final startPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    List<Offset> pieceOffset = <Offset>[];
    for (var vertex in Hex.origin().vertexOffsets) {
      pieceOffset.add(new Offset(
          center.x + hex.point.x + hex.midpoint.x + vertex.x / 14,
          center.y + hex.point.y - hex.midpoint.y - vertex.y / 14));
    }
    Path path = Path();
    path.addPolygon(pieceOffset, true);

    //hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + hex.midpoint.x + p.x, hex.point.y + hex.midpoint.y - p.y)));
    canvas.drawPath(path, startPaint);
  }

  void drawEdgeRulePiece(Hex hex, Point center, Canvas canvas) {
    final edgePaint = Paint()
      ..color = Colors.blueGrey[600]
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    List<Offset> pieceOffset = <Offset>[];
    for (var vertex in hex.vertices) {
      pieceOffset.add(new Offset(
          center.x + vertex.midpoint.x + vertex.point.x,
          center.y - vertex.midpoint.y + vertex.point.y));
    }
    //canvas.drawCircle(Offset(center.x + hex.midpoint.x + hex.point.x, center.y - hex.midpoint.y + hex.point.y), 25, edgePaint);

    canvas.drawLine(
        Offset(center.x + hex.point.x + hex.midpoint.x * 0.6, center.y + hex.point.y - hex.midpoint.y * 0.6),
        Offset(center.x+ hex.point.x - hex.midpoint.x * 0.6, center.y + hex.point.y + hex.midpoint.y * 0.6),
        edgePaint);
    //Path path = Path();
    //path.addPolygon(pieceOffset, true);
    //canvas.drawPath(path, edgePaint);
  }

  void drawPathPiece(Hex hex, Point center, Canvas canvas) {
    final pathPaint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    List<Offset> pieceOffset = <Offset>[];
    hex.vertexOffsets.forEach((Point p) => pieceOffset.add(new Offset(
        center.x + hex.point.x + p.x, center.y + hex.point.y - p.y)));
    canvas.drawLine(pieceOffset[0], pieceOffset[1], pathPaint);
  }

  void drawBoard(Point center, Canvas canvas) {
    List<Offset> boardOffset = <Offset>[];
    var vertexes = vertex.values;
    vertexes.forEach((Point p) => boardOffset.add(Offset(
        center.x + p.x * 2 * _gameState.board.size,
        center.y + p.y * 2 * (_gameState.board.size))));
    var boardPath = Path();
    boardPath.addPolygon(boardOffset, true);
    final boardFillPaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [Colors.lightBlueAccent[100], Colors.lightBlue],
      ).createShader(Rect.fromCircle(
        center: new Offset(center.x, center.y),
        radius: hexSize * 2 * _gameState.board.size,
      ));
    canvas.drawPath(boardPath, boardFillPaint);
    final boardEdgePaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = 15
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.black,
          Colors.grey,
          Colors.black,
        ],
      ).createShader(Rect.fromCircle(
        center: new Offset(center.x, center.y),
        radius: hexSize + hexSize * 2 * (_gameState.board.size - 1),
      ));
    canvas.drawPath(boardPath, boardEdgePaint);
  }

  void paintFill(Canvas canvas, Size size) {
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
            Colors.white,
            Colors.grey[200],
            Colors.white,
          ],
          stops: [
            0.4,
            0.5,
            0.6,
          ]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(fillRect, fillPaint);
  }

  void drawTrail(Point center, Canvas canvas) {
    drawCurrentTrail(_gameState.board, center, canvas);
    drawTrailStartPiece(_gameState.board, center, canvas);
    drawTrailEndPiece(_gameState.board, center, canvas);
  }

  void drawCurrentTrail(Board board, Point center, Canvas canvas) {
    if (board.trail.length > 1) {
      final trailPaint = Paint()
        ..color = board.isFinished
            ? (board.isSuccess ? Colors.amber[200] : Colors.amber[900])
            : Colors.amber
        ..strokeWidth = 8
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

  void drawTrailEndPiece(Board board, Point center, Canvas canvas) {
    if (board.hasEnded) {
      var offset = new Offset(
          center.x + board.tail.point.x + board.tail.midpoint.x,
          center.y + board.tail.point.y - board.tail.midpoint.y);
      final endPaint = Paint()
        ..color = Colors.blueGrey
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.amber[100],
            Colors.amber[600],
            board.isFinished
                ? (board.isSuccess ? Colors.amber[200] : Colors.amber[900])
                : Colors.amber,
          ],
        ).createShader(Rect.fromCircle(
          center: offset,
          radius: hexSize / 5.0,
        ));
      canvas.drawCircle(offset, hexSize / 4.0, endPaint);
    }
  }

  void drawTrailStartPiece(Board board, Point center, Canvas canvas) {
    if (board.trail.length > 0) {
      final startPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.amber[800],
            Colors.amber[700],
            board.isFinished
                ? (board.isSuccess ? Colors.amber[200] : Colors.amber[900])
                : Colors.amber,
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

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }

}