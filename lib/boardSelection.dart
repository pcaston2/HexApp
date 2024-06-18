part of 'main.dart';

class BoardSelection extends StatefulWidget {
  @override
  Boards createState() => new Boards(_flow);
  final BoardFlow _flow;
  BoardSelection(this._flow);
}



class Boards extends State<BoardSelection> {
  BoardFlow _flow;
  Boards(this._flow);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton:
        Visibility(
        visible: settings.developer,
        child: FloatingActionButton(
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
                      var temp = _flow.boardPaths[oldIndex];
                      _flow.boardPaths[oldIndex] = _flow.boardPaths[newIndex];
                      _flow.boardPaths[newIndex]  = temp;
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
                            title: Text(boards[index].name),
                            onTap: () {
                              pushBoard(context, boards, index, _flow);
                            }
                        )
                        );
                      }): []
                );
              }
            }));


  }

  Future<void> pushBoard(BuildContext context, List<Board> boards,int index, BoardFlow flow) async {
    var result = await Navigator.push( context, MaterialPageRoute(builder: (context) => BoardView(boards[index], flow)));
    if (result != null && result) {
      if (boards.every((b) => b.completed)) {
        Navigator.pop(context, true);
      }
      if (boards.length > index +1) {
        pushBoard(context, boards, ++index, flow);
      }
    }
  }
}
