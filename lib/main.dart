import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

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

part 'hexPainter.dart';

Offset focalStart = Offset.zero;

void main() => runApp(HexApp());

get screenSize => Offset(
    hexWidth * maxBoardSize * 2 * 1.25, hexHeight * maxBoardSize * 2 * 1.25);

get screenCenter => Offset(screenSize.dx / 2, screenSize.dy / 2);

class GameState {
  Board board = Board.sample();
  Hex pointer = Hex.origin();
  Piece piece = PathPiece();
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
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    AudioPlayer.logEnabled = true;
    audioPlayer.mode = PlayerMode.LOW_LATENCY;
    _gameState = ValueNotifier<GameState>(GameState());
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

  PathPiece pathPiece = new PathPiece();
  ErasePiece erasePiece = new ErasePiece();
  StartPiece startPiece = new StartPiece();
  EndPiece endPiece = new EndPiece();
  DotRulePiece dotPiece = new DotRulePiece();
  BreakRulePiece breakPiece = new BreakRulePiece();
  EdgeRulePiece edgePiece = new EdgeRulePiece();

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
                        ListTile(
                            title: Text("Play Sound"),
                            onTap: () async {
                              audioPlayer
                                  .play('panel_start_tracing.mp3');
                            }),
                        Text("Design"),
                        PieceTile(pathPiece,
                            () => _choosePiece(context, pathPiece, _gameState)),
                        Text("Terminals"),
                        PieceTile(
                            startPiece,
                            () =>
                                _choosePiece(context, startPiece, _gameState)),
                        PieceTile(endPiece,
                            () => _choosePiece(context, endPiece, _gameState)),
                        Text("Rules"),
                        PieceTile(dotPiece,
                            () => _choosePiece(context, dotPiece, _gameState)),
                        PieceTile(
                            breakPiece,
                            () =>
                                _choosePiece(context, breakPiece, _gameState)),
                        PieceTile(edgePiece,
                            () => _choosePiece(context, edgePiece, _gameState)),
                        Text("Editing"),
                        PieceTile(
                            erasePiece,
                            () =>
                                _choosePiece(context, erasePiece, _gameState)),
                        ListTile(
                            title: Text("JSON MUNGER"),
                            onTap: () {
                              setState(() {
                                //var json = Board.sample().toJson();
                                //print(json);
                                //_gameState.value.board = Board.fromJson(json);
                              });
                            }),
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
                              if (_gameState.value.board.mode ==
                                  BoardMode.play) {
                                if (_gameState.value.board.hasEnded) {
                                  setState(() {
                                    if (_gameState.value.board.trySolve()) {
                                      audioPlayer.play(
                                          'panel_success.mp3',
                                          isLocal: true);
                                    } else {
                                      audioPlayer.play(
                                          'panel_failure.mp3',
                                          isLocal: true);
                                    }
                                  });
                                  tracing = false;
                                } else {
                                  setState(() {
                                    _gameState.value.board.resetTrail();
                                    audioPlayer.play('stop_tracing.mp3',
                                        isLocal: true);
                                  });
                                }
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
                                if (_gameState.value.board.isTail(h)) {
                                  _gameState.value.board.startAt(h);
                                  tracing = true;
                                } else if (_gameState.value.board.isEnd(h)) {
                                  tracing = true;
                                } else if (_gameState.value.board.isStart(h)) {
                                  _gameState.value.board.startAt(h);
                                  audioPlayer
                                      .play('assets/panel_start_tracing.mp3');
                                  if (tracing) {}
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
                                if (_gameState.value.board.moveTo(h)) {
                                  setState(() => _gameState.value.board);
                                }
                              }
                            },
                            child: CustomPaint(
                                painter: HexPainter(_gameState.value))))))));
  }
}
