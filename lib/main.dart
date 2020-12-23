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

void main() => runApp(HexApp());

class GameState {
  Board board = Board.sample();
  Hex pointer = Hex.origin();
  Piece piece = EdgePiece();
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
            body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: (details) {
                  Point p = new Point(
                      details.localPosition.dx, details.localPosition.dy);
                  Hex h = Hex.getHexPartFromPoint(p);
                  //_gameState.value.pointer = h;
                  setState(() => _gameState.value.pointer = h);
                },
                onLongPressEnd: (details) {
                  _gameState.value.board.putPiece(
                      _gameState.value.pointer, _gameState.value.piece);
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
                        onPanUpdate: (details) {
                          var vector = new Point(details.delta.dx, -details.delta.dy);
                          movement += vector;
                        },
                        */
                child: Transform(
                    transform: Matrix4.identity()..rotateZ(3.14 / 12.0),
                    origin: Offset(0,0),
                    transformHitTests: true,
                    child: FractionallySizedBox(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: CustomPaint(
                            painter: HexPainter(_gameState.value))))))
        //
        );
  }
}

class HexPainter extends CustomPainter {
  //         <-- CustomPainter class

  GameState _gameState;
  HexPainter(this._gameState);
  @override
  void paint(Canvas canvas, Size size) {
    var center = Point(
      0, //size.width/2,
      0, //size.height/2
    );
    TextSpan span = new TextSpan(
        style: new TextStyle(color: Colors.blue[800]),
        text: "Selected Piece: ${_gameState.piece.name}");
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(5.0, 5.0));

    var entries = _gameState.board.flatten();
    entries.sort((a, b) => a.value.order.compareTo(b.value.order));
    for (var entry in entries) {
      var hex = entry.key;
      var piece = entry.value;
      if (piece is EdgePiece) {
        final edgePaint = Paint()
          ..color = Colors.blueGrey
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;
        List<Offset> pieceOffset = <Offset>[];
        hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(
            center.x + hex.point.x + p.x, center.y + hex.point.y - p.y)));
        canvas.drawLine(pieceOffset[0], pieceOffset[1], edgePaint);
      } else if (piece is StartPiece) {
        final startPaint = Paint()
          ..color = Colors.blueGrey
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
              center.x + hex.point.x + hex.midpoint.x + vertex.x / 2.5,
              center.y + hex.point.y - hex.midpoint.y - vertex.y / 2.5));
        }
        Path path = new Path();
        path.addPolygon(pieceOffset, true);

        //hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + hex.midpoint.x + p.x, hex.point.y + hex.midpoint.y - p.y)));
        canvas.drawPath(path, startPaint);
      } else if (piece is ErasePiece || piece is ClearPiece) {
        TextSpan errorSpan = new TextSpan(
            style: new TextStyle(color: Colors.red), text: piece.name);
        TextPainter errorPainter = new TextPainter(
            text: errorSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
        errorPainter.layout();
        Offset offset = new Offset(
            hex.point.x + hex.midpoint.x, hex.point.y - hex.midpoint.y);
        errorPainter.paint(canvas, offset);
      } else if (piece is EndPiece) {
        var center = new Offset(
            hex.point.x + hex.midpoint.x, hex.point.y - hex.midpoint.y);
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
            center: center,
            radius: hexSize / 4.0,
          ));
        canvas.drawCircle(center, hexSize / 3.0, endPaint);
      }
    }
    canvas.clipRect(new Rect.fromLTWH(0, 0, size.width, size.height));
    List<Offset> offsets = <Offset>[];
    for (var vertex in _gameState.pointer.vertices) {
      offsets.add(new Offset(center.x + _gameState.pointer.point.x + vertex.x,
          center.y + _gameState.pointer.point.y - vertex.y));
    }
    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    offsets.forEach((Offset offset) => canvas.drawCircle(offset, 5, paint));
    offsets.forEach((Offset offset) => canvas.drawCircle(offset, 10, paint));

    /*
    final fill = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, fill);
    */
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
