part of 'main.dart';


class FlowSelection extends StatefulWidget {
  @override
  Flows createState() => new Flows();
}

const String FLOW_FILE_EXTENSION = "jhexflow";

class Flows extends State<FlowSelection> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          tooltip: "Add a Flow",
          child: Icon(Icons.add_rounded),
          onPressed: () {
            TextEditingController _textFieldController =
                TextEditingController();
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Please Name Your Flow:'),
                    content: TextField(
                      controller: _textFieldController,
                      decoration: InputDecoration(hintText: "My Flow"),
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
                          createFlow(_textFieldController.text).then((value) {
                            final ScaffoldMessengerState scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            scaffoldMessenger.showSnackBar(SnackBar(
                                content: Text(
                                    "Created Flow ${_textFieldController.text}")));
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
          title: Text('Hex Puzzle Game'),
        ),
        body: FutureBuilder(
            future: getFlows(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return new Text('Getting your flows...');
              } else {
                List<BoardFlow> flows = snapshot.data;
                //Text(flows.length.toString());
                return ListView(
                    children:
                        flows.isNotEmpty ?
                        List<ListTile>.generate(flows.length, (int index) {
                  return FlowTile(
                    flow: flows[index],
                    title: Text(flows[index].name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BoardSelection(flows[index])),
                      );
                    }
                  );
                }): Text("There aren't any flows yet, try adding one!"));
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

  static Future<BoardFlow> createFlow(String flowName) async {
    var cacheDir = await getApplicationDocumentsDirectory();
    BoardFlow flow = new BoardFlow.named(flowName);
    File f = File('${cacheDir.path}/${flow.guid}.${FLOW_FILE_EXTENSION}');
    f.writeAsString(json.encode(flow.toJson()));
    return flow;
  }

  static Future<List<BoardFlow>> getFlows() async {
    Directory cacheDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = cacheDir.listSync();
    var flowFiles = files.where((FileSystemEntity entity) =>
        entity.path.contains(".${FLOW_FILE_EXTENSION}"));
    List<BoardFlow> flows = [];
    for (FileSystemEntity fse in flowFiles) {
      try {
        File file = File(fse.path);
        String s = await file.readAsString();
        flows.add(BoardFlow.fromJson(json.decode(s)));
      } on Exception catch (ex) {
        print(ex);
      }
    }
    return flows;
  }
}
