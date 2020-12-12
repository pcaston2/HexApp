import 'package:flutter/foundation.dart';

/// Flutter code sample for RadioListTile

// ![RadioListTile sample](https://flutter.github.io/assets-for-api-docs/assets/material/radio_list_tile.png)
//
// This widget shows a pair of radio buttons that control the `_character`
// field. The field is of the type `SingingCharacter`, an enum.

import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'hex.dart';

void main() => runApp(HexApp());

Point movement;

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
  ValueNotifier<Hex> _hex;

  @override
  void initState() {
    _hex = ValueNotifier<Hex>(Hex.origin());
    super.initState();
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  _HexWidgetState();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _hex,
        builder: (context, value, child) =>
        InteractiveViewer(
            boundaryMargin: EdgeInsets.all(20.0),
            minScale:0.5,
            maxScale:1.5,
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,

                  onTapUp: (details) {
                    Point p = new Point(details.localPosition.dx, details.localPosition.dy);
                    Hex h = Hex.GetHexPartFromPoint(p);
                    _hex.value = h;
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
                      CustomPaint(size: Size(500,500), painter: HexPainter(_hex.value))
              )
        )
    );

  }
}

enum NavigationMode { Face, Edge, Vertex }

/// This is the stateful widget that the main application instantiates.
class NavigationWidget extends StatefulWidget {
  NavigationWidget({Key key}) : super(key: key);
  //NavigationWidget();


  @override
  _NavigationWidgetState createState() => _NavigationWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _NavigationWidgetState extends State<NavigationWidget> {
  _NavigationWidgetState();

  NavigationMode _mode = NavigationMode.Face;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile<NavigationMode>(
          title: const Text('Face'),
          value: NavigationMode.Face,
          groupValue: _mode,
          onChanged: (NavigationMode value) {
            setState(() {
              _mode = value;
            });
          },
        ),
        RadioListTile<NavigationMode>(
          title: const Text('Edge'),
          value: NavigationMode.Edge,
          groupValue: _mode,
          onChanged: (NavigationMode value) {
            setState(() {
              _mode = value;
            });
          },
        ),
        RadioListTile<NavigationMode>(
          title: const Text('Vertex'),
          value: NavigationMode.Vertex,
          groupValue: _mode,
          onChanged: (NavigationMode value) {
            setState(() {
              _mode = value;
            });
          },
        ),
      ],
    );
  }
}

/*

CustomPaint( //                       <-- CustomPaint widget
            size: Size(300, 300),
            painter: MyPainter(),
          ),
 */

class HexPainter extends CustomPainter {
  //         <-- CustomPainter class
  HexPainter(this._hex);
  Hex _hex = new Hex.origin();
  @override
  void paint(Canvas canvas, Size size) {
    print("Painting...");
    final pointMode = ui.PointMode.points;
    List<Offset> offsets = new List<Offset>();
    for (var vertex in _hex.vertices) {
      offsets.add(new Offset(_hex.point.x + vertex.x, _hex.point.y - vertex.y));
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
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, offsets, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
