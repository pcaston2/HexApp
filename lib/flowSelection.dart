part of 'main.dart';


class FlowSelection extends StatefulWidget {
  @override
  Flows createState() => new Flows();
}


class Flows extends State<FlowSelection> {
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
                          BoardFlow.createFlow(_textFieldController.text).then((value) {
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
            future: BoardFlow.getFlows(),
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
                }): [Text("There aren't any flows yet, try adding one!")]);
              }
            }));
  }
}
