part of 'main.dart';

class BoardSelection extends StatefulWidget {
  @override
  Boards createState() => new Boards(_flow, _story);
  final BoardFlow _flow;
  final Story _story;
  BoardSelection(this._flow, this._story);
}



class Boards extends State<BoardSelection> {
  BoardFlow _flow;
  Story _story;
  Boards(this._flow, this._story);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton:
        Visibility(
        visible: settings.developer,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "import",
              tooltip: "Import a Board",
              child: Icon(Icons.file_upload_rounded),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jhexboard'],
                  allowMultiple: true,
                );

                if (result != null) {
                  try {
                    for (var file in result.files) {
                      File f = File(file.path!);
                      String content = await f.readAsString();
                      Board newBoard = await Board.fromImport(content);
                      _flow.boardPaths.add(newBoard.guid);
                    }
                    await _flow.save();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Imported ${result.files.length} Board(s)")));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Error importing board(s): $e")));
                  }
                }
              },
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "add",
              tooltip: "Add a Board",
              child: Icon(Icons.add_rounded),
              onPressed: () {
                TextEditingController _textFieldController =
                TextEditingController();
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Please Name Your Board:'),
                        content: TextField(
                          controller: _textFieldController,
                          decoration: InputDecoration(hintText: "My Board"),
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
                              Board.createBoard(_textFieldController.text).then((Board newBoard) {

                                newBoard.save();
                                _flow.boardPaths.add(newBoard.guid);
                                _flow.save().then((value) => setState(() {}));
                                final ScaffoldMessengerState scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                                scaffoldMessenger.showSnackBar(SnackBar(
                                    content: Text(
                                        "Created Board ${_textFieldController.text}")));
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        )
        ),
        appBar: AppBar(
          title: settings.developer
              ? Row(children: [
            Text(_flow.name),
            IconButton(
                onPressed: () {
                  TextEditingController _textFieldController =
                  TextEditingController();
                  _textFieldController.text =
                      _flow.name;
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Please Rename Your Flow:'),
                          content: TextField(
                            controller: _textFieldController,
                            decoration: InputDecoration(
                                hintText: "My Flow"),
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
                                  _flow.name =
                                      _textFieldController.text;
                                  _flow
                                      .save()
                                      .then((value) =>
                                      setState(() {}));
                                  final ScaffoldMessengerState
                                  scaffoldMessenger =
                                  ScaffoldMessenger.of(context);
                                  scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Flow renamed to ${_textFieldController.text}")));
                                  Navigator.pop(context);
                                })
                          ],
                        );
                      });
                },
                icon: Icon(Icons.edit_rounded))
          ])
              : Text(_flow.name)),
        body: FutureBuilder(
            future: _flow.boards,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return new Text('Getting your boards...');
              } else {
                List<Board> boards = snapshot.data;
                //Text(flows.length.toString());
                return ReorderableListView(
                    buildDefaultDragHandles: settings.developer,
                    onReorder: (int oldIndex, int newIndex) {
                      if (newIndex > oldIndex) {
                        newIndex--;
                      }
                      var moved = _flow.boardPaths.removeAt(oldIndex);
                      _flow.boardPaths.insert(newIndex, moved);
                      _flow.save().then((data) => setState(() {})
                      );
                    },
                    header: boards.isEmpty? Text("There aren't any boards yet, try adding one!") : Text("Pick a board or add some more!"),
                    children:
                      boards.isNotEmpty ?
                      List<Dismissible>.generate(boards.length, (int index) {
                        return Dismissible(
                            key: ValueKey(boards[index].guid),
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                _flow.deleteAt(index).then((data) => setState(() {}));
                              }
                            },
                            confirmDismiss: (DismissDirection direction) async {
                              if (direction == DismissDirection.endToStart) {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Delete Board?"),
                                      content: const Text(
                                          "Are you sure you want to delete this board?"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Heck no!'),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                        ),
                                        TextButton(
                                            child: Text('You bet!'),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            })
                                      ],
                                    );
                                  },
                                );
                              } else {
                                var newBoard = boards[index].clone();
                                newBoard.name += " copy";
                                newBoard.save();
                                _flow.boardPaths.insert(index+1, newBoard.guid);
                                _flow.save().then((value) => setState(() {}));
                                final ScaffoldMessengerState scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                                scaffoldMessenger.showSnackBar(SnackBar(
                                    content: Text(
                                        "Created a copy of ${boards[index].name}")));
                                return false;
                              }
                            },
                            direction: settings.developer ? DismissDirection.horizontal : DismissDirection.none,
                            secondaryBackground: Container(
                              color: Colors.redAccent,
                              child: Icon(Icons.remove_rounded),
                            ),
                            background: Container(
                              color: Colors.blueAccent,
                              child: Icon(Icons.copy),
                            ),
                            child:
                            BoardTile(
                            board: boards[index],
                            completed: settings.isComplete(boards[index].guid),
                            title: Text(boards[index].name),
                            onTap: () {
                              pushBoard(context, boards, index, _flow, _story);
                            }
                        )
                        );
                      }): []
                );
              }
            }));


  }

  Future<void> pushBoard(BuildContext context, List<Board> boards,int index, BoardFlow flow, Story story) async {
    var result = await Navigator.push( context, MaterialPageRoute(builder: (context) => BoardView(boards[index], flow, story)));
    
    if (!mounted) return;
    setState(() {});
    
    if (result != null && result) {
      if (boards.every((b) => settings.isComplete(b.guid))) {
        Navigator.pop(context, true);
      } else if (boards.length > index + 1) {
        pushBoard(context, boards, index + 1, flow, story);
      }
    }
  }
}
