part of 'main.dart';

get screenSize => Offset(
    hexWidth * maxBoardSize * 2 * 1.25, hexHeight * maxBoardSize * 2 * 1.25);

get screenCenter => Offset(screenSize.dx / 2, screenSize.dy / 2);

class GameState {
  Board board = Board.sample();
  Hex pointer = Hex.origin();
  Piece piece = PathPiece();
  RuleColorIndex ruleColor = RuleColorIndex.First;
  Matrix4 transform = Matrix4.identity();
}

bool tracing = false;

class BoardView extends StatefulWidget {
  final Board _board;

  BoardView(this._board, {Key key}) : super(key: key);

  @override
  _HexWidgetState createState() => _HexWidgetState(_board);
}

class _HexWidgetState extends State<BoardView> {
  ValueNotifier<GameState> _gameState;
  SoundPlayer soundPlayer = SoundPlayer();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _gameState.dispose();
    super.dispose();
  }

  _HexWidgetState(Board board) {
    _gameState = ValueNotifier<GameState>(GameState());
    _gameState.value.board = board;
  }

  void _choosePiece(
      BuildContext context, Piece piece, ValueNotifier<GameState> gameState) {
    Navigator.pop(context);
    setState(() => _gameState.value.piece = piece);
  }

  PathPiece pathPiece = new PathPiece();
  ErasePiece erasePiece = new ErasePiece();
  StartPiece startPiece = new StartPiece();
  EndPiece endPiece = new EndPiece();
  DotRule dotPiece = new DotRule();
  BreakRule breakPiece = new BreakRule();
  EdgeRule edgePiece = new EdgeRule();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _gameState,
        builder: (context, value, child) => Scaffold(
            appBar: AppBar(title: Text(_gameState.value.board.name)),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton:
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  FloatingActionButton(
                      heroTag: "mode",
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
                      heroTag: "center",
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
                        ExpansionTile(title: Text("File"), children: [
                          ListTile(
                              title: Text("Save"),
                              onTap: () {
                                _gameState.value.board.save().then((value) {
                                  final ScaffoldMessengerState
                                      scaffoldMessenger =
                                      ScaffoldMessenger.of(context);
                                  scaffoldMessenger.showSnackBar(
                                      SnackBar(content: Text("Saved!")));
                                  Navigator.pop(context);
                                  setState(() {});
                                });
                              }),
                          ListTile(
                              title: Text("Exit"),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                setState(() {});
                              }),
                          ListTile(
                            title: Text("Name: ${_gameState.value.board.name}"),
                            //onTap: () {}
                          ),
                        ]),
                        ExpansionTile(title: Text("Design"), children: [
                          PieceTile(
                              pathPiece,
                              () =>
                                  _choosePiece(context, pathPiece, _gameState)),
                        ]),
                        ExpansionTile(title: Text("Terminals"), children: [
                          PieceTile(
                              startPiece,
                              () => _choosePiece(
                                  context, startPiece, _gameState)),
                          PieceTile(
                              endPiece,
                              () =>
                                  _choosePiece(context, endPiece, _gameState)),
                        ]),
                        ExpansionTile(title: Text("Rules"), children: [
                          DropdownButton<RuleColorIndex>(
                              value: _gameState.value.ruleColor,
                              icon: Icon(Icons.color_lens_outlined),
                              onChanged: (RuleColorIndex newValue) {
                                setState(() {
                                  _gameState.value.ruleColor = newValue;
                                });
                              },
                              items: List<DropdownMenuItem<RuleColorIndex>>.generate(
                                  RuleColorIndex.values.length, (int index) {
                                return DropdownMenuItem<RuleColorIndex>(
                                    value: RuleColorIndex.values[index],
                                    child: Container(
                                      height: 24.0,
                                      width: 24.0,
                                      decoration: BoxDecoration(
                                          color: _gameState.value.board.theme.ruleColors[RuleColorIndex.values[index]].value,
                                          shape: BoxShape.circle),
                                    ));
                              })),
                          PieceTile(
                              dotPiece,
                              () =>
                                  _choosePiece(context, dotPiece, _gameState)),
                          PieceTile(
                              breakPiece,
                              () => _choosePiece(
                                  context, breakPiece, _gameState)),
                          PieceTile(
                              edgePiece,
                              () =>
                                  _choosePiece(context, edgePiece, _gameState)),
                        ]),
                        ExpansionTile(title: Text("Editing"), children: [
                          PieceTile(
                              erasePiece,
                              () => _choosePiece(
                                  context, erasePiece, _gameState)),
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
                                              children: [
                                                Text(
                                                    'Clearing the board will erase everything.'),
                                                Text(
                                                    'Are you sure you want to clear the board?'),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text('Heck no!'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                                child: Text('You bet!'),
                                                onPressed: () {
                                                  _gameState.value.board
                                                      .clear();
                                                  Navigator.of(context).pop();
                                                })
                                          ],
                                        ));
                              }),
                        ]),
                        ExpansionTile(title: Text("Color Theme"), children: [
                          ColorTile(context,
                              color: _gameState.value.board.theme.foreground,
                              title: "Foreground",
                              onSelect: () => setState(() {})),
                          ColorTile(context,
                              color: _gameState.value.board.theme.background,
                              title: "Background",
                              onSelect: () => setState(() {})),
                          ColorTile(context,
                              color: _gameState.value.board.theme.border,
                              title: "Border",
                              onSelect: () => setState(() {})),
                          ColorTile(context,
                              color: _gameState.value.board.theme.path,
                              title: "Path",
                              onSelect: () => setState(() {})),
                          ColorTile(context,
                              color: _gameState.value.board.theme.trail,
                              title: "Trail",
                              onSelect: () => setState(() {})),
                          ExpansionTile(title: Text("Rule Colors"), children: [
                            ColorTile(context,
                                color: _gameState.value.board.theme
                                    .ruleColors[RuleColorIndex.First],
                                title: "First",
                                onSelect: () => setState(() {})),
                            ColorTile(context,
                                color: _gameState.value.board.theme
                                    .ruleColors[RuleColorIndex.Second],
                                title: "Second",
                                onSelect: () => setState(() {})),
                            ColorTile(context,
                                color: _gameState.value.board.theme
                                    .ruleColors[RuleColorIndex.Third],
                                title: "Third",
                                onSelect: () => setState(() {})),
                            ColorTile(context,
                                color: _gameState.value.board.theme
                                    .ruleColors[RuleColorIndex.Fourth],
                                title: "Fourth",
                                onSelect: () => setState(() {})),
                            ColorTile(context,
                                color: _gameState.value.board.theme
                                    .ruleColors[RuleColorIndex.Fifth],
                                title: "Fifth",
                                onSelect: () => setState(() {})),
                          ])
                        ]),
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
                                if (_gameState.value.piece is ColoredRule) {
                                  ColoredRule rule = _gameState.value.piece;
                                  rule.color = _gameState.value.ruleColor;
                                }
                                _gameState.value.board.putPiece(
                                    _gameState.value.pointer,
                                    _gameState.value.piece.clone());
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
                                      soundPlayer
                                          .play(audioSound.PANEL_SUCCESS);
                                    } else {
                                      soundPlayer
                                          .play(audioSound.PANEL_FAILURE);
                                    }
                                  });
                                  tracing = false;
                                } else {
                                  setState(() {
                                    _gameState.value.board.resetTrail();
                                    soundPlayer.play(audioSound.TRACING_END);
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
                                  soundPlayer.play(audioSound.TRACING_START);
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
