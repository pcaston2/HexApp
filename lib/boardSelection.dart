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
        floatingActionButton: FloatingActionButton(
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
                          Board.createBoard(_textFieldController.text).then((Board value) {

                            value.save();
                            _flow.boardPaths.add(value.guid);
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
        appBar: AppBar(
          title: Text(_flow.name),
        ),
        body: FutureBuilder(
            future: _flow.boards,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return new Text('Getting your boards...');
              } else {
                List<Board> boards = snapshot.data;
                //Text(flows.length.toString());
                return ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {
                      print("OLD: $oldIndex NEW: $newIndex");
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
                          key: ValueKey(boards[index].name),
                          onDismissed: (direction) {
                            _flow.boardPaths.removeAt(index);
                            _flow.save().then((data) => setState(() {}));
                          },
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.redAccent,
                            child: Icon(Icons.remove_rounded)
                          ),
                          child:
                          BoardTile(
                          board: boards[index],
                          title: Text(boards[index].name),
                          onTap: () {
                            pushBoard(context, boards, index);
                          }
                      )
                      );
                    }): []
                );
              }
            }));


  }

  Future<void> pushBoard(BuildContext context, List<Board> boards, index) async {
    var result = await Navigator.push( context, MaterialPageRoute(builder: (context) => BoardView(boards[index])));
    if (result != null && result) {
      if (boards.length > index +1) {
        pushBoard(context, boards, ++index);
      }
    }
  }
}
