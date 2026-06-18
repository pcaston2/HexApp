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
    bool isDev = settings.developer;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Visibility(
          visible: isDev,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "import",
                tooltip: "Import a Board",
                child: const Icon(Icons.file_upload_rounded),
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
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
                          content: Text(
                              "Imported ${result.files.length} Board(s)")));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error importing board(s): $e")));
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "add",
                tooltip: "Add a Board",
                child: const Icon(Icons.add_rounded),
                onPressed: () {
                  TextEditingController _textFieldController =
                      TextEditingController();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Please Name Your Board:'),
                          content: TextField(
                            controller: _textFieldController,
                            decoration:
                                const InputDecoration(hintText: "My Board"),
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
                                Board.createBoard(_textFieldController.text)
                                    .then((Board newBoard) {
                                  newBoard.save();
                                  _flow.boardPaths.add(newBoard.guid);
                                  _flow.save()
                                      .then((value) => setState(() {}));
                                  final ScaffoldMessengerState
                                      scaffoldMessenger =
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
          )),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.blueGrey),
          title: isDev
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_flow.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: Colors.blueGrey.shade900)),
                  IconButton(
                      onPressed: () {
                        TextEditingController _textFieldController =
                            TextEditingController();
                        _textFieldController.text = _flow.name;
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Please Rename Your Flow:'),
                                content: TextField(
                                  controller: _textFieldController,
                                  decoration: const InputDecoration(
                                      hintText: "My Flow"),
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
                                        _flow.name =
                                            _textFieldController.text;
                                        _flow.save().then(
                                            (value) => setState(() {}));
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
                      icon: const Icon(Icons.edit_rounded))
                ])
              : Text(_flow.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: Colors.blueGrey.shade900))),
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
              future: _flow.boards,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Text('Getting your boards...',
                          style: TextStyle(color: Colors.white)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Board> boards = snapshot.data ?? [];

                  int completedCount =
                      boards.where((b) => settings.isComplete(b.guid)).length;
                  double progress =
                      boards.isEmpty ? 0 : completedCount / boards.length;

                  Widget progressHeader = Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Flow Progress",
                                style: TextStyle(
                                    color: Colors.blueGrey.shade900.withOpacity(0.7),
                                    fontSize: 14)),
                            Text("${(progress * 100).round()}%",
                                style: TextStyle(
                                    color: Colors.blueGrey.shade900,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.black.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black.withOpacity(0.8)),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isDev) {
                    return ReorderableListView(
                        buildDefaultDragHandles: true,
                        onReorder: (int oldIndex, int newIndex) {
                          if (newIndex > oldIndex) {
                            newIndex--;
                          }
                          var moved = _flow.boardPaths.removeAt(oldIndex);
                          _flow.boardPaths.insert(newIndex, moved);
                          _flow.save().then((data) => setState(() {}));
                        },
                        header: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              boards.isEmpty
                                  ? "There aren't any boards yet, try adding one!"
                                  : "Choose a Board...",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Colors.blueGrey.shade900)),
                        ),
                        children: List<Dismissible>.generate(boards.length,
                            (int index) {
                          return Dismissible(
                              key: ValueKey(boards[index].guid),
                              onDismissed: (direction) {
                                if (direction == DismissDirection.endToStart) {
                                  _flow
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
                                        title: const Text("Delete Board?"),
                                        content: const Text(
                                            "Are you sure you want to delete this board?"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Heck no!'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                              child: const Text('You bet!'),
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
                                  _flow.boardPaths
                                      .insert(index + 1, newBoard.guid);
                                  _flow
                                      .save()
                                      .then((value) => setState(() {}));
                                  final ScaffoldMessengerState
                                      scaffoldMessenger =
                                      ScaffoldMessenger.of(context);
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                      content: Text(
                                          "Created a copy of ${boards[index].name}")));
                                  return false;
                                }
                              },
                              direction: DismissDirection.horizontal,
                              secondaryBackground: Container(
                                color: Colors.redAccent,
                                child: const Icon(Icons.remove_rounded),
                              ),
                              background: Container(
                                color: Colors.blueAccent,
                                child: const Icon(Icons.copy),
                              ),
                              child: BoardTile(
                                  board: boards[index],
                                  completed: false,
                                  title: Text(boards[index].name),
                                  onTap: () {
                                    pushBoard(context, boards, index, _flow,
                                        _story);
                                  }));
                        }));
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        progressHeader,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: Text("Choose a Board...",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Colors.blueGrey.shade900)),
                        ),
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
                            itemCount: boards.length,
                            itemBuilder: (context, index) {
                              return BoardGridTile(
                                board: boards[index],
                                completed:
                                    settings.isComplete(boards[index].guid),
                                index: index,
                                onTap: () => pushBoard(
                                    context, boards, index, _flow, _story),
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
    );
  }

  Future pushBoard(BuildContext context, List<Board> boards, int index, BoardFlow flow, Story story) async {
    final navigator = Navigator.of(context);
    var result = await navigator.push(
        SlideRoute(
            page: BoardView(boards, index, flow, story)));

    if (!mounted) return null;
    setState(() {});

    if (result == true) {
      if (boards.every((b) => settings.isComplete(b.guid))) {
        navigator.pop(true);
      }
      return true;
    }
    return null;
  }
}
