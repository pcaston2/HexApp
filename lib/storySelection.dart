part of 'main.dart';

class StorySelection extends StatefulWidget {
  @override
  Stories createState() => new Stories();

}

class Stories extends State<StorySelection> {
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
          title: Text('Stories',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: 1.2,
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
                future: Story.getStories(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Text("Getting your stories...",
                            style: TextStyle(color: Colors.white)));
                  } else {
                    List<Story> stories = snapshot.data ?? [];

                    if (isDev) {
                      return ListView(
                          padding: const EdgeInsets.all(16),
                          children: stories.isNotEmpty
                              ? List<ListTile>.generate(stories.length,
                                  (int index) {
                                  return StoryTile(
                                      story: stories[index],
                                      completed: false,
                                      title: Text(stories[index].name),
                                      onTap: () async {
                                              var result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FlowSelection(
                                                            stories[index])),
                                              );
                                              if (!mounted) return;
                                              setState(() {});
                                              if (result != null && result) {
                                                settings.setComplete(
                                                    stories[index].guid);
                                                stories[index].save();
                                                setState(() {});
                                              }
                                            });
                                      })
                              : [
                                  const Text(
                                      "There aren't any stories yet, try adding one!")
                                ]);
                    } else {
                      return GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: stories.length,
                        itemBuilder: (context, index) {
                          return StoryGridTile(
                            story: stories[index],
                            completed:
                                settings.isComplete(stories[index].guid),
                            index: index,
                            onTap: () async {
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FlowSelection(stories[index])),
                              );
                              if (!mounted) return;
                              setState(() {});
                              if (result != null && result) {
                                settings.setComplete(stories[index].guid);
                                stories[index].save();
                                setState(() {});
                              }
                            },
                          );
                        },
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
                tooltip: "Add Story",
                child: const Icon(Icons.add_rounded),
                onPressed: () {
                  TextEditingController _textFieldController =
                      TextEditingController();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Please Name Your Story:'),
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
                                print(_textFieldController.text);
                                Story.createStory(_textFieldController.text)
                                    .then((value) {
                                  final ScaffoldMessengerState
                                      scaffoldMessenger =
                                      ScaffoldMessenger.of(context);
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                      content: Text(
                                          "Created Story ${_textFieldController.text}")));
                                  setState(() {});
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                })),
    );
  }
}