import 'package:flutter/foundation.dart';

/// Flutter code sample for RadioListTile

// ![RadioListTile sample](https://flutter.github.io/assets-for-api-docs/assets/material/radio_list_tile.png)
//
// This widget shows a pair of radio buttons that control the `_character`
// field. The field is of the type `SingingCharacter`, an enum.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pieceTile.dart';

import 'piece.dart';
import 'board.dart';

import 'hex.dart';

Offset focalStart = Offset.zero;

void main() => runApp(HexApp());

get screenSize => Offset(
    hexWidth * maxBoardSize * 2 * 1.25, hexHeight * maxBoardSize * 2 * 1.25);

get screenCenter => Offset(screenSize.dx / 2, screenSize.dy / 2);

class GameState {
  Board board = Board.sample();
  Hex pointer = Hex.origin();
  Piece piece = EdgePiece();
  Matrix4 transform = Matrix4.identity();
}

bool tracing = false;

/// This is the main application widget.
class HexApp extends StatelessWidget {
  static const String _title = 'Hex App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: _title, home: HexWidget());
  }
}

class HexWidget extends StatefulWidget {
  HexWidget({Key key}) : super(key: key);

  @override
  _HexWidgetState createState() => _HexWidgetState();
}

class _HexWidgetState extends State<HexWidget> {
  ValueNotifier<GameState> _gameState;

  @override
  void initState() {
    _gameState = ValueNotifier<GameState>(GameState());
    super.initState();
  }

  @override
  void dispose() {
    _gameState.dispose();
    super.dispose();
  }

  _HexWidgetState();

  void _choosePiece(
      BuildContext context, Piece piece, ValueNotifier<GameState> gameState) {
    Navigator.pop(context);
    setState(() => _gameState.value.piece = piece);
  }

  EdgePiece edgePiece = new EdgePiece();
  ErasePiece erasePiece = new ErasePiece();
  StartPiece startPiece = new StartPiece();
  EndPiece endPiece = new EndPiece();
  DotPiece dotPiece = new DotPiece();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _gameState,
        builder: (context, value, child) => Scaffold(
            appBar: AppBar(title: Text('Hex Game')),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton:
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  FloatingActionButton(
                      onPressed: () => setState(() {
                            if (_gameState.value.board.mode == BoardMode.play) {
                              setState(() => _gameState.value.board.mode =
                                  BoardMode.designer);
                            } else {
                              setState(() =>
                                  _gameState.value.board.mode = BoardMode.play);
                            }
                          }),
                      tooltip: _gameState.value.board.mode == BoardMode.play
                          ? 'Designer Mode'
                          : 'Play Mode',
                      child: _gameState.value.board.mode == BoardMode.play
                          ? Icon(Icons.build_rounded)
                          : Icon(Icons.play_arrow_rounded)),
                  FloatingActionButton(
                      onPressed: () => setState(() {
                            _gameState.value.transform = Matrix4.identity();
                          }),
                      tooltip: 'Re-Center',
                      child: const Icon(Icons.home))
                ]),
            drawer: _gameState.value.board.mode == BoardMode.play
                ? null
                : Drawer(
                    child: ListView(
                      // Important: Remove any padding from the ListView.
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        DrawerHeader(
                          child: Text('Tools'),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                        ),

                        PieceTile(startPiece,
                            () => _choosePiece(context, startPiece, _gameState)),
                        PieceTile(edgePiece,
                            () => _choosePiece(context, edgePiece, _gameState)),
                        PieceTile(endPiece,
                            () => _choosePiece(context, endPiece, _gameState)),
                        PieceTile(dotPiece,
                            () => _choosePiece(context, dotPiece, _gameState)),
                        PieceTile(erasePiece,
                            () => _choosePiece(context, erasePiece, _gameState)),
                        ListTile(
                            title: Text("Clear All"),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: Text('Clear board?'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text(
                                                  'Clearing the board will erase everything.'),
                                              Text(
                                                  'Are you sure you want to clear the board?'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Heck no!'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                              child: Text('You bet!'),
                                              onPressed: () {
                                                _gameState.value.board.clear();
                                                Navigator.of(context).pop();
                                              })
                                        ],
                                      ));
                            }),

                        /*
                      title: Text('Item 2'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                      },
                    ),
                      */
                      ],
                    ),
                  ),
            body: OverflowBox(
                maxHeight: screenSize.dy,
                maxWidth: screenSize.dx,
                child: SizedBox.expand(
                    child: Transform(
                        transform: _gameState.value.transform,
                        transformHitTests: true,
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onLongPressEnd: (details) {},
                            onTapUp: (details) {
                              var p = Point(
                                  details.localPosition.dx - screenCenter.dx,
                                  details.localPosition.dy - screenCenter.dy);
                              var h = Hex.getHexPartFromPoint(p);
                              if (_gameState.value.board.mode ==
                                  BoardMode.designer) {
                                var p = Point(
                                    details.localPosition.dx - screenCenter.dx,
                                    details.localPosition.dy - screenCenter.dy);
                                var h = Hex.getHexPartFromPoint(p);
                                if (_gameState.value.board.pieceOnBoard(h)) {
                                  setState(() => _gameState.value.pointer = h);
                                }
                              } else {
                                /*
                                setState(() => _gameState.value.board.startAt(h));
                                 */
                              }
                            },
                            onDoubleTap: () {
                              if (_gameState.value.board.mode ==
                                  BoardMode.designer) {
                                _gameState.value.board.putPiece(
                                    _gameState.value.pointer,
                                    _gameState.value.piece);
                                setState(() => _gameState);
                              } else {
                                //set state try to start
                              }
                            },
                            /*
                        onPanStart: (details) {

                          movement = new Point.origin();

                        },
                        onPanEnd: (details) {

                          var vector = movement;
                          if (vector != null && vector.magnitude > 10) {
                            var closest = vector.closest(edge.values.toList());
                            var direction = edge.entries
                                .singleWhere((element) => element.value == closest)
                                .key;
                            print(direction);
                            print("${_hex.value.q},${_hex.value.r}");
                            _hex.value += direction;
                            print("${_hex.value.q},${_hex.value.r}");
                          } else {
                            print("Move was too small");
                          }
                          movement = null;

                        },
                         */
                            onScaleEnd: (details) {
                              if (_gameState.value.board.hasEnded) {
                                setState(
                                    () => _gameState.value.board.trySolve());
                                tracing = false;
                              }
                            },
                            onScaleStart: (details) {
                              focalStart = details.focalPoint;
                              if (_gameState.value.board.mode ==
                                  BoardMode.play) {
                                var p = Point(
                                    details.localFocalPoint.dx -
                                        screenCenter.dx,
                                    details.localFocalPoint.dy -
                                        screenCenter.dy);
                                var h = Hex.getHexPartFromPoint(p);
                                if  (_gameState.value.board.isTail(h)) {
                                  _gameState.value.board.startAt(h);
                                  tracing = true;
                                } else if (_gameState.value.board.isEnd(h)) {
                                  tracing = true;
                                } else if (_gameState.value.board.isStart(h)) {
                                  _gameState.value.board.startAt(h);
                                  tracing = true;
                                } else {
                                  tracing = false;
                                }
                              }
                              setState(() {});
                            },
                            onScaleUpdate: (details) {
                              if (!_gameState.value.board.hasStarted ||
                                  !tracing) {
                                var offsetDelta =
                                    details.focalPoint - focalStart;
                                focalStart = details.focalPoint;
                                setState(() {
                                  var transform = _gameState.value.transform;
                                  //var current = transform.getTranslation();
                                  //print('current: $current');
                                  //transform.translate(-current.x, -current.y);
                                  //var focal = details.localFocalPoint;
                                  //print('focal: $focal');

                                  //transform.translate(focal.dx, focal.dy);
                                  // transform.scale(
                                  //     1 - (1 - details.scale) / 150.0,
                                  //     1 - (1 - details.scale) / 150.0
                                  // );
                                  //transform.rotateZ(details.rotation / 90);
                                  //transform.translate(-focal.dx, -focal.dy);
                                  //transform.translate(current.x, current.y);
                                  transform.translate(
                                      offsetDelta.dx, offsetDelta.dy);
                                });
                              } else {
                                var p = Point(
                                    details.localFocalPoint.dx -
                                        screenCenter.dx,
                                    details.localFocalPoint.dy -
                                        screenCenter.dy);
                                var h = Hex.getHexPartFromPoint(p);
                                if (h.runtimeType == Vertex) {
                                  if (_gameState.value.board.moveTo(h)) {
                                    setState(() => _gameState.value.board);
                                  }
                                }
                              }
                            },
                            child: CustomPaint(
                                painter: HexPainter(_gameState.value))))))));
  }
}

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
      if (piece is EdgePiece) {
        drawEdgePiece(hex, center, canvas);
      } else if (piece is StartPiece) {
        drawStartPiece(hex, center, canvas);
      } else if (piece is EndPiece) {
        drawEndPiece(hex, center, canvas);
      } else if (piece is DotPiece) {
        drawDotPiece(hex, center, canvas);
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


  void drawDotPiece(Hex hex, Point center, Canvas canvas) {
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

  void drawEdgePiece(Hex hex, Point center, Canvas canvas) {
    final edgePaint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    List<Offset> pieceOffset = <Offset>[];
    hex.vertexOffsets.forEach((Point p) => pieceOffset.add(new Offset(
        center.x + hex.point.x + p.x, center.y + hex.point.y - p.y)));
    canvas.drawLine(pieceOffset[0], pieceOffset[1], edgePaint);
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
      board.trail.forEach((Vertex v) => trailOffset.add(new Offset(
          center.x + v.point.x + v.midpoint.x,
          center.y + v.point.y - v.midpoint.y)));
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
