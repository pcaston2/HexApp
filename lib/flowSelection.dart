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
    bool isDev = settings.developer;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
        title: isDev
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_story.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.blueGrey.shade900)),
                IconButton(
                    onPressed: () {
                      TextEditingController _textFieldController =
                          TextEditingController();
                      _textFieldController.text = _story.name;
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Please Rename Your Story:'),
                              content: TextField(
                                controller: _textFieldController,
                                decoration:
                                    const InputDecoration(hintText: "My Story"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('CANCEL'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      _story.name = _textFieldController.text;
                                      _story.save().then(
                                          (value) => setState(() {}));
                                      final ScaffoldMessengerState
                                          scaffoldMessenger =
                                          ScaffoldMessenger.of(context);
                                      scaffoldMessenger.showSnackBar(SnackBar(
                                          content: Text(
                                              "Story renamed to ${_textFieldController.text}")));
                                      Navigator.pop(context);
                                    })
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.edit_rounded))
              ])
            : Text(_story.name,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Colors.blueGrey.shade900)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDev
                ? [Colors.white, Colors.grey.shade200]
                : [
                    Colors.blueGrey.shade50,
                    Colors.blueGrey.shade200,
                    Colors.blueGrey.shade400,
                  ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder(
              future: _story.flows,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Text('Getting your flows...',
                          style: TextStyle(color: Colors.white)));
                } else {
                  List<BoardFlow> flows = snapshot.data ?? [];

                  int completedCount =
                      flows.where((f) => settings.isComplete(f.guid)).length;
                  double progress =
                      flows.isEmpty ? 0 : completedCount / flows.length;

                  Widget progressHeader = Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Story Progress",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14)),
                            Text("${(progress * 100).round()}%",
                                style: const TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.tealAccent),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isDev) {
                    return ReorderableListView(
                        buildDefaultDragHandles: true,
                        padding: const EdgeInsets.all(16),
                        onReorder: (int oldIndex, int newIndex) {
                          if (newIndex > oldIndex) {
                            newIndex--;
                          }
                          var moved = _story.flowPaths.removeAt(oldIndex);
                          _story.flowPaths.insert(newIndex, moved);
                          _story.save().then((data) => setState(() {}));
                        },
                        header: flows.isEmpty
                            ? const Text(
                                "There aren't any flows yet, try adding one!")
                            : const Text("Pick a flow or add some more!"),
                        children: List<Dismissible>.generate(flows.length,
                            (int index) {
                          return Dismissible(
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.redAccent,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete_rounded,
                                    color: Colors.white),
                              ),
                              key: ValueKey(flows[index].guid),
                              onDismissed: (direction) {
                                if (direction == DismissDirection.endToStart) {
                                  _story
                                      .deleteAt(index)
                                      .then((data) => setState(() {}));
                                }
                              },
                              confirmDismiss:
                                  (DismissDirection direction) async {
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
                                                child: const Text('Heck no!'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                }),
                                            TextButton(
                                                child: const Text('You bet!'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                })
                                          ],
                                        );
                                      });
                                } else {
                                  return false;
                                }
                              },
                              child: FlowTile(
                                  flow: flows[index],
                                  completed: false,
                                  title: Text(flows[index].name),
                                  onTap: () async {
                                    var result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BoardSelection(
                                              flows[index], _story)),
                                    );
                                    if (!mounted) return;
                                    setState(() {});
                                    if (result != null && result) {
                                      settings.setComplete(flows[index].guid);
                                      flows[index].save();
                                      if (flows.every((f) =>
                                          settings.isComplete(f.guid))) {
                                        Navigator.pop(context, true);
                                      }
                                    }
                                  }));
                        }));
                  } else {
                    return Column(
                      children: [
                        progressHeader,
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: flows.length,
                            itemBuilder: (context, index) {
                              return FlowGridTile(
                                flow: flows[index],
                                completed:
                                    settings.isComplete(flows[index].guid),
                                index: index,
                                onTap: () async {
                                  var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BoardSelection(
                                            flows[index], _story)),
                                  );
                                  if (!mounted) return;
                                  setState(() {});
                                  if (result != null && result) {
                                    settings.setComplete(flows[index].guid);
                                    flows[index].save();
                                    if (flows.every((f) =>
                                        settings.isComplete(f.guid))) {
                                      Navigator.pop(context, true);
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                }
              }),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Visibility(
        visible: isDev,
        child: FloatingActionButton(
          tooltip: "Add a Flow",
          child: const Icon(Icons.add_rounded),
          onPressed: () {
            TextEditingController _textFieldController =
                TextEditingController();
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Please Name Your Flow:'),
                    content: TextField(
                      controller: _textFieldController,
                      decoration: const InputDecoration(hintText: "My Flow"),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          BoardFlow.createFlow(_textFieldController.text)
                              .then((BoardFlow newFlow) {
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
    );
  }
}
