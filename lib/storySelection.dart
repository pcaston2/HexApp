part of 'main.dart';

class StorySelection extends StatefulWidget {
  @override
  Stories createState() => new Stories();

}

class Stories extends State<StorySelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton:
        Visibility(
          visible: settings.developer,
            child:
              FloatingActionButton(
                tooltip: "Add Story",
                child: Icon(Icons.add_rounded),
                onPressed: () {
                  TextEditingController _textFieldController =
                  TextEditingController();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Please Name Your Story:'),
                          content: TextField(
                            controller: _textFieldController,
                            decoration: InputDecoration(hintText: "My Story"),
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
                                Story.createStory(_textFieldController.text).then((value) {
                                  final ScaffoldMessengerState scaffoldMessenger =
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
                }
              )
        ),
      appBar: AppBar(
        title: Text('Stories'),
      ),
      backgroundColor: settings.developer ? null : Colors.blueGrey.shade900,
      body: FutureBuilder(
        future: Story.getStories(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return new Text("Getting your stories...");
          } else {
            List<Story> stories = snapshot.data;

            if (settings.developer) {
              return ListView(
                children:
                  stories.isNotEmpty ?
                      List<ListTile>.generate(stories.length, (int index) {
                        return StoryTile(
                          story: stories[index],
                          completed: settings.isComplete(stories[index].guid),
                          title: Text(stories[index].name),
                          onTap: () async {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FlowSelection(stories[index])),
                            );
                            if (!mounted) return;
                            setState(() {});
                            if (result != null && result) {
                              settings.setComplete(stories[index].guid);
                              stories[index].save();
                              setState(() {});
                            }
                          }
                        );
                      }) : [Text("There aren't any stories yet, try adding one!")]);
            } else {
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  return StoryGridTile(
                    story: stories[index],
                    completed: settings.isComplete(stories[index].guid),
                    index: index,
                    onTap: () async {
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FlowSelection(stories[index])),
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
        }
      )
    );
  }
}