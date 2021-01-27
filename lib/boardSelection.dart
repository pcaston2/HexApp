part of 'main.dart';


class BoardSelection extends StatefulWidget {
  @override
  Boards createState() => new Boards(_flow);
  BoardFlow _flow;

  BoardSelection(this._flow);
}


const String BOARD_FILE_EXTENSION = "jhexboard";

class Boards extends State<BoardSelection> {
  BoardFlow _flow;
  Boards(this._flow);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _id;
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
                          print(_textFieldController.text);
                          createBoard(_textFieldController.text).then((Board value) {
                            _flow.boards.add(value.guid);
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
            future: getBoards(),
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
                            print(boards[index].guid);
                          }
                      );
                    }): Text("There aren't any boards yet, try adding one!"));
              }
            }));
  }
  // ListView(
  //     children: List.generate(10, (int index) {
  //   return new ListTile(
  //     title: Text("item#$index"),
  //     onTap: () {
  //       setState(() {
  //         _id = index;
  //       });
  //       print(_id);
  //     },
  //   );

  // Board readBoard(String filename) {
  //   assert(basePath != null, "The base file path must be loaded");
  //   File f = File('$basePath/$filename.jboard');
  //   String s = f.readAsStringSync();
  //   return Board.fromJson(json.decode(s));
  // }

  Future<Board> createBoard(String boardName) async {
    var cacheDir = await getApplicationDocumentsDirectory();
    Board board = new Board.named(boardName);
    File f = File('${cacheDir.path}/${board.guid}.${BOARD_FILE_EXTENSION}');
    f.writeAsString(json.encode(board.toJson()));
    return board;
  }

  Future<List<Board>> getBoards() async {
    Directory cacheDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = cacheDir.listSync();
    var flowFiles = files.where((FileSystemEntity entity) =>
        entity.path.contains(".${BOARD_FILE_EXTENSION}"));
    List<Board> boards = [];
    for (FileSystemEntity fse in flowFiles) {
      try {
        File file = File(fse.path);
        String s = await file.readAsString();
        boards.add(Board.fromJson(json.decode(s)));
      } on Exception catch (ex) {
        print(ex);
      }
    }
    return boards;
  }
}
