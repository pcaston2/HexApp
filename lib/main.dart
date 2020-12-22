import 'package:flutter/foundation.dart';

/// Flutter code sample for RadioListTile

// ![RadioListTile sample](https://flutter.github.io/assets-for-api-docs/assets/material/radio_list_tile.png)
//
// This widget shows a pair of radio buttons that control the `_character`
// field. The field is of the type `SingingCharacter`, an enum.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pieceTile.dart';

import 'dart:ui' as ui;
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
    return MaterialApp(
        title: _title,
        home: HexWidget()
    );
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

  void _choosePiece(BuildContext context, Piece piece, ValueNotifier<GameState> gameState) {
    Navigator.pop(context);
    setState(() => _gameState.value.piece = piece);
  }
  EdgePiece edgePiece = new EdgePiece();
  ErasePiece erasePiece = new ErasePiece();
  StartPiece startPiece = new StartPiece();
  ClearPiece clearPiece = new ClearPiece();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _gameState,
        builder: (context, value, child) =>
            Scaffold(
              appBar: AppBar(title: Text('Hex Game')),
              drawer: Drawer(
                child:ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      child: Text('Tools'),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                    ),
                    PieceTile(edgePiece, () => _choosePiece(context, edgePiece, _gameState)),
                    PieceTile(erasePiece, () => _choosePiece(context, erasePiece, _gameState)),
                    PieceTile(startPiece, () => _choosePiece(context, startPiece, _gameState)),
                    PieceTile(clearPiece, () => _choosePiece(context, clearPiece, _gameState)),

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
              body:
                  GestureDetector(
                      behavior: HitTestBehavior.translucent,

                      onTapUp: (details) {
                        Point p = new Point(details.localPosition.dx, details.localPosition.dy);
                        Hex h = Hex.getHexPartFromPoint(p);
                        //_gameState.value.pointer = h;
                        setState(() => _gameState.value.pointer = h);
                      },
                      onLongPressEnd: (details) {
                        _gameState.value.board.putPiece(_gameState.value.pointer, _gameState.value.piece);
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
                      child: FractionallySizedBox(
                            widthFactor: 1.0,
                            heightFactor: 1.0,
                            child:
                                CustomPaint(painter: HexPainter(_gameState.value))

                        ),


                  )
            )
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
    TextSpan span = new TextSpan(style: new TextStyle(color: Colors.blue[800]), text: "Selected Piece: ${_gameState.piece.name}");
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(5.0, 5.0));


    for(Hex hex in _gameState.board.keys) {
      for(var piece in _gameState.board.getPiecesAt(hex)) {
        if (piece is EdgePiece) {
          final edgePaint = Paint()
            ..color = Colors.blueGrey
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round;
          List<Offset> pieceOffset = <Offset>[];
          hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + p.x, hex.point.y - p.y)));
          canvas.drawLine(pieceOffset[0],pieceOffset[1], edgePaint);
        } else if (piece is StartPiece) {
          final startPaint = Paint()
              ..color = Colors.blueGrey
              ..style = PaintingStyle.fill
              ..shader = RadialGradient(
                colors: [
                  Colors.blueGrey[100],
                  Colors.blueGrey,
                ],
              ).createShader(Rect.fromCircle(
                center: new Offset(hex.point.x + hex.midpoint.x, hex.point.y - hex.midpoint.y),
                radius: hexSize / 5.0,
              ));
          List<Offset> pieceOffset = <Offset>[];
          final polygonMode = ui.PointMode.polygon;
          //canvas.drawCircle(new Offset(hex.point.x + hex.midpoint.x, hex.point.y + hex.midpoint.y), 20, startPaint);
          for (var vertex in Hex.origin().vertices) {
            pieceOffset.add(new Offset(hex.point.x + hex.midpoint.x + vertex.x/4, hex.point.y - hex.midpoint.y - vertex.y/4));
          }
          Path path = new Path();
          path.addPolygon(pieceOffset, true);

          //hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + hex.midpoint.x + p.x, hex.point.y + hex.midpoint.y - p.y)));
          canvas.drawPath(path,startPaint);
        } else if (piece is ErasePiece || piece is ClearPiece) {
          TextSpan errorSpan = new TextSpan(style: new TextStyle(color: Colors.red), text: piece.name);
          TextPainter errorPainter = new TextPainter(text: errorSpan, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
          errorPainter.layout();
          Offset offset = new Offset(hex.point.x + hex.midpoint.x, hex.point.y - hex.midpoint.y);
          errorPainter.paint(canvas, offset);
        }

      }
    }

    canvas.clipRect(new Rect.fromLTWH(0,0,size.width, size.height));
    final pointMode = ui.PointMode.points;
    List<Offset> offsets = <Offset>[];
    for (var vertex in _gameState.pointer.vertices) {
      offsets.add(new Offset(_gameState.pointer.point.x + vertex.x, _gameState.pointer.point.y - vertex.y));
    }
    /*
    var east = _hex.point + vertex[VertexDirection.East];
    var northEast = _hex.point + vertex[VertexDirection.NorthEast];
    var northWest = _hex.point + vertex[VertexDirection.NorthWest];
    var west = _hex.point + vertex[VertexDirection.West];
    var southWest = _hex.point + vertex[VertexDirection.SouthWest];
    var southEast = _hex.point + vertex[VertexDirection.SouthEast];
    final points = [
      Offset(east.x, east.y),
      Offset(northEast.x, northEast.y),
      Offset(northWest.x, northWest.y),
      Offset(west.x, west.y),
      Offset(southWest.x, southWest.y),
      Offset(southEast.x, southEast.y)
    ];
    */
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
