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
                            _flow.save();
                            final ScaffoldMessengerState scaffoldMessenger =
                            ScaffoldMessenger.of(context);
                            scaffoldMessenger.showSnackBar(SnackBar(
                                content: Text(
                                    "Created Board ${_textFieldController.text}")));
                            setState(() {});
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
                return ListView(
                    children:
                    boards.isNotEmpty ?
                    List<ListTile>.generate(boards.length, (int index) {
                      return BoardTile(
                          board: boards[index],
                          title: Text(boards[index].name),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BoardView(boards[index])),
                            );
                          }
                      );
                    }): [Text("There aren't any boards yet, try adding one!")]);
              }
            }));
  }

}
