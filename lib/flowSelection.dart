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
        backgroundColor: settings.developer ? null : Colors.blueGrey.shade900,
        body: FutureBuilder(
            future: _story.flows,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return new Text('Getting your flows...');
              } else {
                List<BoardFlow> flows = snapshot.data;

                if (settings.developer) {
                  return ReorderableListView(
                      buildDefaultDragHandles: true,
                      onReorder: (int oldIndex, int newIndex) {
                        if (newIndex > oldIndex) {
                          newIndex--;
                        }
                        var moved = _story.flowPaths.removeAt(oldIndex);
                        _story.flowPaths.insert(newIndex, moved);
                        _story.save().then((data) => setState(() {})
                        );
                      },
                      header: flows.isEmpty ? Text("There aren't any flows yet, try adding one!") : Text("Pick a flow or add some more!"),
                      children:
                          List<Dismissible>.generate(flows.length, (int index) {
                    return
                      Dismissible(
                        direction: DismissDirection.endToStart,
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
                          } else {
                            return false;
                          }
                      },
                      child: FlowTile(
                      flow: flows[index],
                      completed: settings.isComplete(flows[index].guid),
                      title: Text(flows[index].name),
                      onTap: () async {
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BoardSelection(flows[index], _story)),
                        );
                        if (!mounted) return;
                        setState(() {});
                        if (result != null && result) {
                          settings.setComplete(flows[index].guid);
                          flows[index].save();
                          if (flows.every((f) => settings.isComplete(f.guid))) {
                            Navigator.pop(context, true);
                          }
                        }
                      }
                    ));
                  })
                  );
                } else {
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: flows.length,
                    itemBuilder: (context, index) {
                      return FlowGridTile(
                        flow: flows[index],
                        completed: settings.isComplete(flows[index].guid),
                        index: index,
                        onTap: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BoardSelection(flows[index], _story)),
                          );
                          if (!mounted) return;
                          setState(() {});
                          if (result != null && result) {
                            settings.setComplete(flows[index].guid);
                            flows[index].save();
                            if (flows.every((f) => settings.isComplete(f.guid))) {
                              Navigator.pop(context, true);
                            }
                          }
                        },
                      );
                    },
                  );
                }
              }
            }));
  }
}
