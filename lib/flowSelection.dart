part of 'main.dart';


class FlowSelection extends StatefulWidget {
  @override
  Flows createState() => new Flows(_story);
  final Story _story;
  FlowSelection(this._story);
}


class Flows extends State<FlowSelection> {
  Story _story;
  Flows(this._story);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton:
            Visibility(
              visible: settings.developer,
              child: FloatingActionButton(
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
                                BoardFlow.createFlow(_textFieldController.text).then((BoardFlow newFlow) {
                                  newFlow.save();
                                  _story.flowPaths.add(newFlow.guid);
                                  _story.save().then((value) => setState(() {}));
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
            ),
        appBar: AppBar(

          title: settings.developer
              ? Row(children: [
            Text(_story.name),
            IconButton(
                onPressed: () {
                  TextEditingController _textFieldController =
                  TextEditingController();
                  _textFieldController.text =
                      _story.name;
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Please Rename Your Story:'),
                          content: TextField(
                            controller: _textFieldController,
                            decoration: InputDecoration(
                                hintText: "My Story"),
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
                                  _story.name =
                                      _textFieldController.text;
                                  _story
                                      .save()
                                      .then((value) =>
                                      setState(() {}));
                                  final ScaffoldMessengerState
                                  scaffoldMessenger =
                                  ScaffoldMessenger.of(context);
                                  scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Story renamed to ${_textFieldController.text}")));
                                  Navigator.pop(context);
                                })
                          ],
                        );
                      });
                },
                icon: Icon(Icons.edit_rounded))
          ])
              : Text(_story.name),
        ),
        body: FutureBuilder(
            future: _story.flows,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return new Text('Getting your flows...');
              } else {
                List<BoardFlow> flows = snapshot.data;
                //Text(flows.length.toString());
                return ReorderableListView(
                    buildDefaultDragHandles: settings.developer,
                    onReorder: (int oldIndex, int newIndex) {
                      if (newIndex > oldIndex) {
                        newIndex--;
                      }
                      var temp = _story.flowPaths[oldIndex];
                      _story.flowPaths[oldIndex] = _story.flowPaths[newIndex];
                      _story.flowPaths[newIndex] = temp;
                      _story.save().then((data) => setState(() {})
                      );
                    },
                    header: flows.isEmpty ? Text("There aren't any flows yet, try adding one!") : Text("Pick a flow or add some more!"),
                    children:
                        flows.isNotEmpty ?
                        List<Dismissible>.generate(flows.length, (int index) {
                  return
                    Dismissible(
                      direction: settings.developer ? DismissDirection.endToStart : DismissDirection.none,
                      background: Container(
                        color: Colors.redAccent,
                        child: Icon(Icons.remove_rounded),
                      ),
                      key: ValueKey(flows[index].guid),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _story.deleteAt(index).then((data) => setState(() {}));
                        }
                      },
                      confirmDismiss: (DismissDirection direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Delete Flow?"),
                                content: const Text(
                                  "Are you sure you want to delete this flow?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Heck no!'),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    }
                                  ),
                                  TextButton(
                                    child: Text('You bet!'),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    }
                                  )
                                ],
                              );
                            }
                          );
                        }
                    },
                    child: FlowTile(
                    flow: flows[index],
                    title: Text(flows[index].name),
                    onTap: () async {
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BoardSelection(flows[index])),
                      );
                      if (result != null && result) {
                        flows[index].completed = true;
                        flows[index].save();
                      }
                    }
                  ));
                }): []
                );
              }
            }));
  }
}
