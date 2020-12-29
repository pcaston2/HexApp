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
    hexWidth * maxBoardSize * 2 * 1.25,
    hexHeight * maxBoardSize * 2 * 1.25
);

get screenCenter => Offset(screenSize.dx / 2, screenSize.dy / 2);

class GameState {
  Board board = Board.sample();
  Hex pointer = Hex.origin();
  Piece piece = EdgePiece();
  Matrix4 transform = Matrix4.identity();
}


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
  ClearPiece clearPiece = new ClearPiece();
  EndPiece endPiece = new EndPiece();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _gameState,
        builder: (context, value, child) => Scaffold(
            appBar: AppBar(title: Text('Hex Game')),
            floatingActionButton: FloatingActionButton(
                onPressed: () => setState(() {
                      _gameState.value.transform = Matrix4.identity();
                    }),
                tooltip: 'Re-Center',
                child: const Icon(Icons.home)),
            drawer: Drawer(
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
                  PieceTile(edgePiece,
                      () => _choosePiece(context, edgePiece, _gameState)),
                  PieceTile(startPiece,
                      () => _choosePiece(context, startPiece, _gameState)),
                  PieceTile(endPiece,
                      () => _choosePiece(context, endPiece, _gameState)),
                  PieceTile(erasePiece,
                      () => _choosePiece(context, erasePiece, _gameState)),
                  PieceTile(clearPiece,
                      () => _choosePiece(context, clearPiece, _gameState)),

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
                            onTapUp: (details) {
                              var offset = details.localPosition;
                              var p = Point(
                                  details.localPosition.dx - screenCenter.dx,
                                  details.localPosition.dy - screenCenter.dy
                              );
                              var h = Hex.getHexPartFromPoint(p);
                              if (_gameState.value.board.pieceOnBoard(h)) {
                                setState(() => _gameState.value.pointer = h);
                              }
                            },
                            onDoubleTap: () {
                              _gameState.value.board.putPiece(
                                  _gameState.value.pointer,
                                  _gameState.value.piece);
                              setState(() => _gameState);
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
                            onScaleStart: (details) {
                              focalStart = details.focalPoint;
                            },
                            onScaleUpdate: (details) {
                              var offsetDelta = details.focalPoint - focalStart;
                              //print("Offset: $offsetDelta");
                              //print("Rotation: ${details.rotation}");
                              //print("Scale: ${details.scale}");
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
                                transform.translate( offsetDelta.dx, offsetDelta.dy);
                              });
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
      } else {
        drawErrorPiece(hex, center, piece, canvas);
      }
    }
    drawSelection(center, canvas);
  }

  void drawSelection(Point center, Canvas canvas) {
    List<Offset> offsets = <Offset>[];
    for (var vertex in _gameState.pointer.vertices) {
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
    var offset = new Offset(
        center.x + hex.point.x + hex.midpoint.x,
        center.y + hex.point.y - hex.midpoint.y
    );
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
    TextSpan errorSpan = new TextSpan(
        style: new TextStyle(color: Colors.red), text: piece.name);
    TextPainter errorPainter = new TextPainter(
        text: errorSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    errorPainter.layout();
    Offset offset = new Offset(
        center.x + hex.point.x + hex.midpoint.x,
        center.y + hex.point.y - hex.midpoint.y
    );
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
    for (var vertex in Hex.origin().vertices) {
      pieceOffset.add(new Offset(
          center.x + hex.point.x + hex.midpoint.x + vertex.y / 3.5,
          center.y + hex.point.y - hex.midpoint.y - vertex.x / 3.5));
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
    hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(
        center.x + hex.point.x + p.x,
        center.y + hex.point.y - p.y)));
    canvas.drawLine(pieceOffset[0], pieceOffset[1], edgePaint);
  }

  void drawBoard(Point center, Canvas canvas) {
    List<Offset> boardOffset = <Offset>[];
    var vertexes = vertex.values;
    vertexes.forEach((Point p) => boardOffset.add(Offset (
        center.x + p.x * 2 * _gameState.board.size,
        center.y + p.y * 2 * (_gameState.board.size)
      )));
    var boardPath = Path();
    boardPath.addPolygon(boardOffset, true);
    final boardFillPaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.lightBlueAccent[100],
          Colors.lightBlue
        ],
      ).createShader(Rect.fromCircle(
        center: new Offset(
            center.x,
            center.y
        ),
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
        center: new Offset(
            center.x,
            center.y
        ),
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

    var fillRect = Rect.fromLTWH(0,0,size.width, size.height);

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
        ]
      ).createShader(Rect.fromLTWH(0,0,size.width, size.height));
    canvas.drawRect(fillRect, fillPaint);

  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
