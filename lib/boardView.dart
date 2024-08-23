part of 'main.dart';

class GameState {
  Board board = Board.sample();
  BoardFlow flow = BoardFlow();
  Story story = Story();
  Hex pointer = Hex.origin();
  List<Piece> lastUsed = [StartPiece(), EndPiece(), PathPiece(),BreakPiece(), ErasePiece()];
  BoardAnimation boardAnimation = new BoardAnimation();
  RuleColorIndex ruleColor = RuleColorIndex.First;
}

bool tracing = false;

Point traceOffset = Point.origin();


class BoardView extends StatefulWidget {
  final Board _board;
  final BoardFlow _flow;
  final Story _story;
  BoardView(this._board, this._flow, this._story) : super();

  @override
  _HexWidgetState createState() {
    GameAnalytics.addProgressionEvent({
      "progressionStatus": 1, //START
      "progression01": _story.name,
      "progression02": _flow.name,
      "progression03": _board.name
    });
    return _HexWidgetState(_board, _flow, _story);
  }
}

class _HexWidgetState extends State<BoardView> with TickerProviderStateMixin {
  late ValueNotifier<GameState> _gameState;

  double? _rating = null;

  late HexPainter painter;

  SoundPlayer soundPlayer = SoundPlayer();

  late Animation<double> beckon;
  late AnimationController beckonController;

  late Animation<double> pulse;
  late AnimationController pulseController;

  late Animation<double> fade;
  late AnimationController fadeController;

  late Animation<double> error;
  late AnimationController errorController;

  @override
  void initState() {
    super.initState();


    beckonController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );
    Tween<double> growTween = Tween(begin: 0, end: 1);
    beckon = growTween.animate(beckonController)
      ..addListener(() {
        _gameState.value.boardAnimation.beckon = beckon.value;
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          beckonController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          beckonController.forward();
        }
      });
    beckonController.forward();

    pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    Tween<double> pulseTween = Tween(begin: -1, end: 1);
    pulse = pulseTween.animate(pulseController)
      ..addListener(() {
        _gameState.value.boardAnimation.pulse = pulse.value;
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          pulseController.repeat(reverse: true);
        } else if (status == AnimationStatus.dismissed) {
          pulseController.forward();
        }
      });
    pulseController.forward();

    fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    Tween<double> fadeTween = Tween(begin: 1, end: 0);
    fade = fadeTween.animate(fadeController)
      ..addListener(() {
        _gameState.value.boardAnimation.fade = fade.value;
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          errorController.reset();
          _gameState.value.boardAnimation.error = 0;
          errorController.value = 0;
          if (!tracing && _gameState.value.board.isSuccess == false) {
            _gameState.value.board.resetTrail();
          }
          setState(() {});
        }
      });

    errorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    Tween<double> errorTween = Tween(begin: -1, end: 1);
    error = errorTween.animate(errorController)
      ..addListener(() {
        _gameState.value.boardAnimation.error = error.value;
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          errorController.repeat(reverse: true);
        }
      });
  }

  @override
  void dispose() {
    _gameState.dispose();
    pulseController.dispose();
    fadeController.dispose();
    errorController.dispose();
    beckonController.dispose();
    super.dispose();
  }

  _HexWidgetState(Board board, BoardFlow flow, story) {
    _gameState = ValueNotifier<GameState>(GameState());
    _gameState.value.board = board;
    _gameState.value.flow = flow;
    _gameState.value.story = story;
  }

  void _choosePieceFromMenu(Piece piece) {
    Navigator.pop(context);
    _choosePiece(piece);
  }

  void _choosePiece(Piece piece) {
    var lastUsed = _gameState.value.lastUsed;
    if (lastUsed.first == piece) {
      return;
    } else if (lastUsed.contains(piece)) {
      lastUsed.remove(piece);
    }
    lastUsed.insert(0, piece);
    while (lastUsed.length > 7) {
      lastUsed.removeLast();
    }
  }

  PathPiece pathPiece = new PathPiece();
  BreakPiece breakPiece = new BreakPiece();
  ErasePiece erasePiece = new ErasePiece();
  StartPiece startPiece = new StartPiece();
  EndPiece endPiece = new EndPiece();
  DotRule dotRule = new DotRule();
  SequenceRule colorRule = new SequenceRule();
  EdgeRule edgeRule = new EdgeRule();
  CornerRule cornerRule = new CornerRule();

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
        valueListenable: _gameState,
        builder: (context, value, child) => Scaffold(
            appBar: AppBar(
                title: _gameState.value.board.mode == BoardMode.designer
                    ? Row(children: [
                        Text(_gameState.value.board.name),
                        IconButton(
                            onPressed: () {
                              TextEditingController _textFieldController =
                                  TextEditingController();
                              _textFieldController.text =
                                  _gameState.value.board.name;
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Please Rename Your Board:'),
                                      content: TextField(
                                        controller: _textFieldController,
                                        decoration: InputDecoration(
                                            hintText: "My Board"),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('CANCEL'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              _gameState.value.board.name =
                                                  _textFieldController.text;
                                              _gameState.value.board
                                                  .save()
                                                  .then((value) =>
                                                      setState(() {}));
                                              final ScaffoldMessengerState
                                                  scaffoldMessenger =
                                                  ScaffoldMessenger.of(context);
                                              scaffoldMessenger.showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Board renamed to ${_textFieldController.text}")));
                                              Navigator.pop(context);
                                            })
                                      ],
                                    );
                                  });
                            },
                            icon: Icon(Icons.edit_rounded))
                      ])
                    : Text(_gameState.value.board.name)),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Visibility(
                      visible: settings.developer,
                      child: FloatingActionButton(
                          heroTag: "mode",
                          onPressed: () => setState(() {
                                if (_gameState.value.board.mode ==
                                    BoardMode.play) {
                                  setState(() => _gameState.value.board.mode =
                                      BoardMode.designer);
                                } else {
                                  setState(() => _gameState.value.board.mode =
                                      BoardMode.play);
                                }
                              }),
                          tooltip: _gameState.value.board.mode == BoardMode.play
                              ? 'Designer Mode'
                              : 'Play Mode',
                          child: _gameState.value.board.mode == BoardMode.play
                              ? Icon(Icons.design_services_rounded)
                              : Icon(Icons.play_arrow_rounded))),
                  Visibility(
                    child: FloatingActionButton(
                      heroTag: "next",
                      onPressed: () => setState(() {
                        Navigator.pop(context, true);
                      }),
                      tooltip: 'Next',
                      child: const Icon(Icons.navigate_next_rounded),
                    ),
                    visible: _gameState.value.board.completed &&
                        _gameState.value.board.mode == BoardMode.play,
                  ),
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
                        ExpansionTile(
                            title: Text("File"),
                            leading: Icon(Icons.menu),
                            children: [
                              ListTile(
                                  trailing: Icon(Icons.save),
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
                                  trailing: Icon(Icons.share_rounded),
                                  title: Text("Share"),
                                  onTap: () {
                                    var boardData =
                                        _gameState.value.board.toBase64();
                                    Navigator.of(context)
                                        .push(MaterialPageRoute<void>(
                                      fullscreenDialog: true,
                                      builder: (BuildContext context) {
                                        return Scaffold(
                                          appBar: AppBar(
                                            title: Text(
                                                _gameState.value.board.name),
                                            leading: IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                          ),
                                          body: Center(
                                            child: QrImageView(
                                              data: boardData,
                                              version: QrVersions.auto,
                                              errorStateBuilder: (cxt, err) {
                                                return Container(
                                                  child: Center(
                                                    child: Text(
                                                      'Uh oh! Something went wrong... ${err.toString()}',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ));
                                  }),
                              ListTile(
                                  trailing: Icon(Icons.arrow_back_rounded),
                                  title: Text("Exit"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    setState(() {});
                                  }),
                            ]),
                        ExpansionTile(
                            title: Text("Design"),
                            leading: Icon(Icons.design_services_rounded),
                            children: [
                              ListTile(
                                leading: IconButton(
                                    onPressed: () {
                                      setState(
                                          () => _gameState.value.board.size--);
                                      _gameState.value.board.save();
                                    },
                                    icon: Icon(Icons.remove_rounded)),
                                title: Text(
                                    "Size: ${_gameState.value.board.size}"),
                                trailing: IconButton(
                                    onPressed: () {
                                      setState(
                                          () => _gameState.value.board.size++);
                                      _gameState.value.board.save();
                                    },
                                    icon: Icon(Icons.add_rounded)),
                              ),
                              PieceTile(
                                  pathPiece,
                                  () => _choosePieceFromMenu(pathPiece)),
                              PieceTile(
                                  breakPiece,
                                  () => _choosePieceFromMenu(breakPiece)),
                            ]),
                        ExpansionTile(
                            title: Text("Terminals"),
                            leading: Icon(Icons.adjust_rounded),
                            children: [
                              PieceTile(
                                  startPiece,
                                  () => _choosePieceFromMenu(startPiece)),
                              PieceTile(
                                  endPiece,
                                  () => _choosePieceFromMenu(endPiece)),
                            ]),
                        ExpansionTile(
                            title: Text("Rules"),
                            leading: Icon(Icons.rule_rounded),
                            children: [
                              DropdownButton<RuleColorIndex>(
                                  value: _gameState.value.ruleColor,
                                  icon: Icon(Icons.color_lens_outlined),
                                  onChanged: (RuleColorIndex? newValue) {
                                    setState(() {
                                      _gameState.value.ruleColor = newValue!;
                                    });
                                  },
                                  items: List<
                                          DropdownMenuItem<
                                              RuleColorIndex>>.generate(
                                      RuleColorIndex.values.length,
                                      (int index) {
                                    return DropdownMenuItem<RuleColorIndex>(
                                        value: RuleColorIndex.values[index],
                                        child: Container(
                                          height: 24.0,
                                          width: 24.0,
                                          decoration: BoxDecoration(
                                              color: _gameState
                                                  .value
                                                  .board
                                                  .theme
                                                  .ruleColors[RuleColorIndex
                                                      .values[index]]
                                                  ?.value,
                                              shape: BoxShape.circle),
                                        ));
                                  })),
                              PieceTile(
                                  dotRule,
                                  () => _choosePieceFromMenu(dotRule)),
                              PieceTile(
                                  colorRule,
                                  () => _choosePieceFromMenu(colorRule)),
                              PieceTile(
                                  edgeRule,
                                  () => _choosePieceFromMenu(edgeRule)),
                              PieceTile(
                                  cornerRule,
                                  () => _choosePieceFromMenu(cornerRule)),
                            ]),
                        ExpansionTile(
                            title: Text("Editing"),
                            leading: Icon(Icons.edit_rounded),
                            children: [
                              PieceTile(
                                  erasePiece,
                                  () => _choosePieceFromMenu(erasePiece)),
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
                                                    Text('Clearing the board will erase everything.'),
                                                    Text('Are you sure you want to clear the board?'),
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
                                                      Navigator.of(context)
                                                          .pop();
                                                      _gameState.value.board
                                                          .save();
                                                    })
                                              ],
                                            ));
                                  }),
                            ]),
                        ExpansionTile(
                            title: Text("Color Theme"),
                            leading: Icon(Icons.color_lens_rounded),
                            children: [
                              ColorTile(context,
                                  color:
                                      _gameState.value.board.theme.foreground,
                                  title: "Foreground", onSelect: () {
                                setState(() {});
                                _gameState.value.board.save();
                              }),
                              ColorTile(context,
                                  color:
                                      _gameState.value.board.theme.background,
                                  title: "Background", onSelect: () {
                                setState(() {});
                                _gameState.value.board.save();
                              }),
                              ColorTile(context,
                                  color: _gameState.value.board.theme.border,
                                  title: "Border", onSelect: () {
                                setState(() {});
                                _gameState.value.board.save();
                              }),
                              ColorTile(context,
                                  color: _gameState.value.board.theme.path,
                                  title: "Path", onSelect: () {
                                setState(() {});
                                _gameState.value.board.save();
                              }),
                              ColorTile(context,
                                  color: _gameState.value.board.theme.trail,
                                  title: "Trail", onSelect: () {
                                setState(() {});
                                _gameState.value.board.save();
                              }),
                              ExpansionTile(
                                  title: Text("Rule Colors"),
                                  leading: Icon(Icons.colorize_rounded),
                                  children: [
                                    ColorTile(context,
                                        color: _gameState.value.board.theme
                                            .ruleColors[RuleColorIndex.First]!,
                                        title: "First", onSelect: () {
                                      setState(() {});
                                      _gameState.value.board.save();
                                    }),
                                    ColorTile(context,
                                        color: _gameState.value.board.theme
                                            .ruleColors[RuleColorIndex.Second]!,
                                        title: "Second", onSelect: () {
                                      setState(() {});
                                      _gameState.value.board.save();
                                    }),
                                    ColorTile(context,
                                        color: _gameState.value.board.theme
                                            .ruleColors[RuleColorIndex.Third]!,
                                        title: "Third", onSelect: () {
                                      setState(() {});
                                      _gameState.value.board.save();
                                    }),
                                    ColorTile(context,
                                        color: _gameState.value.board.theme
                                            .ruleColors[RuleColorIndex.Fourth]!,
                                        title: "Fourth", onSelect: () {
                                      setState(() {});
                                      _gameState.value.board.save();
                                    }),
                                    ColorTile(context,
                                        color: _gameState.value.board.theme
                                            .ruleColors[RuleColorIndex.Fifth]!,
                                        title: "Fifth", onSelect: () {
                                      setState(() {});
                                      _gameState.value.board.save();
                                    }),
                                  ]),
                              ListTile(
                                  title: Text("Apply Theme To Flow"),
                                  leading: Icon(Icons.content_copy_rounded),
                                  onTap: () {
                                    Navigator.pop(context);
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                              title:
                                                  Text('Apply Theme to Flow?'),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: [
                                                    Text(
                                                        'This will overwrite all board themes in this flow with the current theme.'),
                                                    Text(
                                                        'Are you sure you want to apply this theme to all boards in the flow?'),
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
                                                    onPressed: () async {
                                                      await _gameState
                                                          .value.flow
                                                          .applyThemeToAll(
                                                              _gameState.value
                                                                  .board.theme)
                                                          .then((value) {
                                                        final ScaffoldMessengerState
                                                            scaffoldMessenger =
                                                            ScaffoldMessenger
                                                                .of(context);
                                                        scaffoldMessenger
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    "Theme has been applied!")));
                                                        setState(() {});
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    })
                                              ],
                                            ));
                                  }),
                              ExpansionTile(
                                  title: Text("Default Themes"),
                                  leading: Icon(Icons.brush_rounded),
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.brush_rounded, color: BoardTheme.yellow().foreground.value),
                                      title: Text('Yellow'),
                                      onTap: () {
                                        setState(() {
                                          _gameState.value.board.theme = BoardTheme.yellow();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.brush_rounded, color: BoardTheme.red().foreground.value),
                                      title: Text('Red'),
                                      onTap: () {
                                        setState(() {
                                          _gameState.value.board.theme = BoardTheme.red();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.brush_rounded, color: BoardTheme.blue().foreground.value),
                                      title: Text('Blue'),
                                      onTap: () {
                                        setState(() {
                                          _gameState.value.board.theme = BoardTheme.blue();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.brush_rounded, color: BoardTheme.gray().foreground.value),
                                      title: Text('Gray'),
                                      onTap: () {
                                        _gameState.value.board.theme = BoardTheme.gray();
                                        _gameState.value.board.save();
                                        Navigator.of(context).pop();
                                      }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.green().foreground.value),
                                        title: Text('Green'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.green();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.highContrast().foreground.value),
                                        title: Text('High Contrast'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.highContrast();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.shale().foreground.value),
                                        title: Text('Shale'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.shale();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.orangeAccent().border.value),
                                        title: Text('Orange Accent'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.orangeAccent();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.purpleAccent().border.value),
                                        title: Text('Purple Accent'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.purpleAccent();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.greenAccent().border.value),
                                        title: Text('Green Accent'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.greenAccent();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.mustard().border.value),
                                        title: Text('Mustard'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.mustard();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.brown().foreground.value),
                                        title: Text('Brown'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.brown();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.darkBlue().foreground.value),
                                        title: Text('Dark Blue'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.darkBlue();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.antique().foreground.value),
                                        title: Text('Antique'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.antique();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.adventure().foreground.value),
                                        title: Text('Adventure'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.adventure();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.fall().foreground.value),
                                        title: Text('Fall'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.fall();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.desaturation().foreground.value),
                                        title: Text('Desaturation'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.desaturation();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.vintage().foreground.value),
                                        title: Text('Vintage'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.vintage();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.contemporary().foreground.value),
                                        title: Text('Contemporary'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.contemporary();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.woods().foreground.value),
                                        title: Text('Woods'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.woods();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.marigold().path.value),
                                        title: Text('Marigold'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.marigold();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.pastel().foreground.value),
                                        title: Text('Pastel'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.pastel();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.neutral().foreground.value),
                                        title: Text('Neutral'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.neutral();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.army().foreground.value),
                                        title: Text('Army'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.army();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.cold().foreground.value),
                                        title: Text('Cold'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.cold();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.mellow().foreground.value),
                                        title: Text('Mellow'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.mellow();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.greek().foreground.value),
                                        title: Text('Greek'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.greek();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.brush_rounded, color: BoardTheme.plain().foreground.value),
                                        title: Text('Plain'),
                                        onTap: () {
                                          _gameState.value.board.theme = BoardTheme.plain();
                                          _gameState.value.board.save();
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                  ]
                              ),
                            ]),
                      ],
                    ),
                  ),
            body: Stack(children: [
              Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      0.4,
                      0.5,
                      0.6,
                    ],
                    colors: [
                      _gameState.value.board.theme.background.value,
                      _gameState.value.board.theme.background.darken(10).value,
                      _gameState.value.board.theme.background.value,
                    ],
                  )),
                  child: Center(
                      child: AspectRatio(
                          aspectRatio: hexHeight / hexWidth,
                          child: FittedBox(
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              child: SizedBox(
                                  width: _gameState.value.board.screenSize.x,
                                  height: _gameState.value.board.screenSize.y,
                                  child: GestureDetector(
                                      trackpadScrollCausesScale: true,
                                      behavior: HitTestBehavior.translucent,
                                      onTapUp: (details) {
                                        var p = Point(details.localPosition.dx,
                                            details.localPosition.dy);
                                        p -=
                                            _gameState.value.board.screenCenter;
                                        var h = Hex.getHexPartFromPoint(p);
                                        if (_gameState.value.board.mode ==
                                            BoardMode.designer) {
                                          if (_gameState.value.board
                                              .pieceOnBoard(h)) {
                                            setState(() =>
                                                _gameState.value.pointer = h);
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
                                          var clone =
                                              _gameState.value.lastUsed.first.clone();
                                          if (clone is ColoredRule) {
                                            ColoredRule rule = clone;
                                            rule.color =
                                                _gameState.value.ruleColor;
                                          } else if (clone is SequenceRule) {
                                            SequenceRule rule = clone;
                                            rule.colors.add(
                                                _gameState.value.ruleColor);
                                          }
                                          if (!_gameState.value.board.putPiece(
                                              _gameState.value.pointer,
                                              clone)) {
                                            soundPlayer
                                                .play(audioSound.PANEL_FAILURE);
                                          } else {
                                            _gameState.value.board.save();
                                          }
                                          setState(() => _gameState);
                                        }
                                      },
                                      onScaleEnd: (details) {
                                        setState(() => _gameState
                                            .value.board.crosshair = null);
                                        if (_gameState.value.board.mode ==
                                            BoardMode.play) {
                                          if (_gameState.value.board.hasEnded) {
                                            if (tracing) {
                                              setState(() {
                                                if (_gameState.value.board.trySolve()) {
                                                  soundPlayer.play(
                                                      audioSound.PANEL_SUCCESS);

                                                  if (!_gameState.value.board.completed) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) =>
                                                            AlertDialog(
                                                              title: Text('Congratulations!'),
                                                              content: SingleChildScrollView(
                                                                child: ListBody(
                                                                  children: [
                                                                    Text('You solved ${_gameState.value.board.name}'),
                                                                    Text('Please take a moment to rate this puzzle'),

                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                RatingStars(
                                                                    valueLabelVisibility: false,
                                                                    value: 5,
                                                                    starSize: 40,
                                                                    onValueChanged: (v) {
                                                                      setState(
                                                                              () {
                                                                            _rating = v;
                                                                            print(_rating);
                                                                            Navigator.of(context).pop();
                                                                          }
                                                                      );
                                                                    }
                                                                ),
                                                                TextButton(
                                                                  child: Text('Heck no!'),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                              ],
                                                            ));
                                                    var gaMap = {
                                                      "progressionStatus": 2, //SUCCESS
                                                      "progression01": _gameState.value.story.name,
                                                      "progression02": _gameState.value.flow.name,
                                                      "progression03": _gameState.value.board.name,
                                                    };
                                                    if (_rating != null) {
                                                      gaMap["score"] = _rating!;
                                                    }
                                                    GameAnalytics.addProgressionEvent(gaMap);
                                                    _gameState.value.board.completed = true;
                                                    _gameState.value.board.save();

                                                  }
                                                } else {
                                                  soundPlayer.play(
                                                      audioSound.PANEL_FAILURE);
                                                  if (!_gameState.value.board.completed) {
                                                    GameAnalytics
                                                        .addProgressionEvent({
                                                      "progressionStatus": 3,
                                                      //FAILURE
                                                      "progression01": _gameState.value.story.name,
                                                      "progression02": _gameState.value.flow.name,
                                                      "progression03": _gameState.value.board.name,
                                                    });
                                                  }
                                                  fadeController.reset();
                                                  fadeController.forward();
                                                  errorController.reset();
                                                  errorController.forward();
                                                }
                                              });
                                              tracing = false;
                                            }
                                          } else {
                                            tracing = false;
                                            _gameState.value.board.resetTrail();
                                            soundPlayer
                                                .play(audioSound.TRACING_END);
                                            setState(() => {});
                                          }
                                          beckonController.reset();
                                          beckonController.forward();
                                        }
                                      },
                                      onScaleStart: (details) {
                                        if (_gameState.value.board.mode ==
                                            BoardMode.play) {
                                          var p = Point(
                                              details.localFocalPoint.dx,
                                              details.localFocalPoint.dy);
                                          p -= _gameState
                                              .value.board.screenCenter;
                                          var h = Hex.getClosestFromPoint(
                                              p,
                                              _gameState.value.board
                                                  .getPiece<StartPiece>());
                                          if (h != null) {
                                            traceOffset = h.localPoint - p;
                                            if (traceOffset.magnitude <
                                                50 *
                                                    _gameState
                                                        .value.board.size) {
                                              setState(() => _gameState
                                                  .value
                                                  .board
                                                  .crosshair = h.localPoint);
                                              if (_gameState.value.board
                                                  .isStart(h)) {
                                                _gameState.value.board
                                                    .startAt(h);
                                                soundPlayer.play(
                                                    audioSound.TRACING_START);
                                                if (tracing) {
                                                  soundPlayer.play(
                                                      audioSound.TRACING_END);
                                                }
                                                tracing = true;
                                              } else {
                                                tracing = false;
                                              }
                                            } else {
                                              tracing = false;
                                            }
                                          }
                                          beckonController.reset();
                                          beckonController.forward();
                                        }
                                        setState(() {});
                                      },
                                      onTap: () {
                                        if (_gameState.value.board.mode ==
                                            BoardMode.play) {
                                          if (_gameState
                                              .value.board.hasStarted) {
                                            tracing = false;
                                            _gameState.value.board.resetTrail();
                                            soundPlayer
                                                .play(audioSound.TRACING_END);
                                            setState(() => {});
                                          }
                                        }
                                      },
                                      onScaleUpdate: (details) {
                                        var p = Point(
                                            details.localFocalPoint.dx,
                                            details.localFocalPoint.dy);
                                        p -=
                                            _gameState.value.board.screenCenter;
                                        p += traceOffset;
                                        if (_gameState.value.board.crosshair !=
                                            null) {
                                          setState(() => _gameState
                                              .value.board.crosshair = p);
                                        }
                                        var h = Hex.getHexPartFromPoint(p);
                                        if (_gameState.value.board.moveTo(h)) {
                                          setState(
                                              () => _gameState.value.board);
                                        }
                                      },
                                      child: CustomPaint(
                                          painter: HexPainter(
                                              _gameState.value)))))))),
              Visibility(
                visible: _gameState.value.board.mode == BoardMode.designer,
                child: Align(
                alignment: Alignment.topCenter,
                  child: Wrap(
                    spacing: 10,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var piece in _gameState.value.lastUsed)
                        Transform.scale(
                          scale: (1/(((_gameState.value.lastUsed.indexOf(piece)+2))/3))*1.15,
                          child: PieceButton(
                              piece,
                              (() {
                                _choosePiece(piece);
                              }),
                              _gameState.value.board.theme.ruleColors[_gameState.value.ruleColor]!.value,
                          )
                        )
                    ]
                  )
                )
              ),
              Visibility(
                visible: _gameState.value.board.mode == BoardMode.designer,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 5,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var colorIndex in _gameState.value.board.theme.ruleColors.keys)
                        Transform.scale(
                          scale: (colorIndex == _gameState.value.ruleColor ? 1.5 : 1),
                          child: IconButton(
                            tooltip: colorIndex.name,
                            onPressed: () {
                              _gameState.value.ruleColor = colorIndex;
                            },
                            icon: Icon(Icons.palette_rounded, color: _gameState.value.board.theme.ruleColors[colorIndex]!.value),
                          )
                        )
                    ]
                  )
                )
              )

            ])));
  }
}
