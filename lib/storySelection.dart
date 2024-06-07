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
          visible: developer,
            child:
              FloatingActionButton(
                tooltip: "Add a Story",
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
        title: Text('Thex'),
      ),
      body: FutureBuilder(
        future: Story.getStories(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return new Text("Getting your stories...");
          } else {
            List<Story> stories = snapshot.data;
            return ListView(
              children:
                stories.isNotEmpty ?
                    List<ListTile>.generate(stories.length, (int index) {
                      return StoryTile(
                        story: stories[index],
                        title: Text(stories[index].name),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FlowSelection(stories[index])),
                          );
                        }
                      );
                    }) : [Text("There aren't any stories yet, try adding one!")]);
          }
        }
      )
    );
  }
}