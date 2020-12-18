import 'package:flutter/foundation.dart';

/// Flutter code sample for RadioListTile

// ![RadioListTile sample](https://flutter.github.io/assets-for-api-docs/assets/material/radio_list_tile.png)
//
// This widget shows a pair of radio buttons that control the `_character`
// field. The field is of the type `SingingCharacter`, an enum.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
        home: Scaffold(
          appBar: AppBar(title: const Text(_title)),
          body: HexWidget(),
        ));
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
                      child: Text('Drawer Header'),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                    ),
                    ListTile(
                      title: Text('Item 1'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                      },
                    ),
                    ListTile(
                      title: Text('Item 2'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                      },
                    ),
                  ],
                ),
              ),
              body: ListView(
                children: [
                  GestureDetector(
                      behavior: HitTestBehavior.translucent,

                      onTapUp: (details) {
                        Point p = new Point(details.localPosition.dx, details.localPosition.dy);
                        Hex h = Hex.getHexPartFromPoint(p);
                        print("${h.q},${h.r}");
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
                      child:
                        new Container(
                            height: 500,
                            width: 500,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent),
                            ),
                            child:
                                CustomPaint(painter: HexPainter(_gameState.value))

                        ),


                  ),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        RaisedButton(
                          child: Text(
                            'Fill'
                          )
                        )
                      ]
                    )
                  )
                ]
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


    for(Hex hex in _gameState.board.keys) {
      for(var piece in _gameState.board.getPiecesAt(hex)) {
        if (piece is EdgePiece) {
          final piecePaint = Paint()
            ..color = Colors.blueGrey
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round;
          List<Offset> pieceOffset = <Offset>[];
          hex.vertices.forEach((Point p) => pieceOffset.add(new Offset(hex.point.x + p.x, hex.point.y - p.y)));
          canvas.drawLine(pieceOffset[0],pieceOffset[1], piecePaint);
        }
      }
    }

    canvas.clipRect(new Rect.fromLTWH(0,0,size.width, size.height));
    print("Painting...");
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
