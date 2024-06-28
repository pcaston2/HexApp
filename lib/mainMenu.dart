part of 'main.dart';

class MainMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainMenuWidget();
}


class MainMenuWidget extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('THEX')
        )
      ),
      body:
      Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: <Widget>[
            ElevatedButton.icon(
              icon: Icon(Icons.play_arrow_rounded),
              iconAlignment: IconAlignment.end,
              label: Text("Play"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StorySelection()),
                );
              },
            ),
            ElevatedButton.icon(
              icon: Icon((settings.sound ? Icons.volume_up_rounded : Icons.volume_mute_rounded)),
              iconAlignment: IconAlignment.end,
              onPressed: () {
                setState(() {
                  settings.sound = !settings.sound;
                });
              },
              label: Text(settings.sound ? "Sound" : "No Sound"),
            ),
            ElevatedButton.icon(
                icon: Icon((settings.developer ? Icons.design_services_rounded : Icons.play_arrow_rounded)),
                iconAlignment: IconAlignment.end,
                label: Text(settings.developer ? "Design Mode" : "Play Mode"),
                onPressed: () {
                  setState(() {
                    settings.developer = !settings.developer;
                  });
                },
            ),
            Visibility(
              visible: settings.developer,
              child: ElevatedButton.icon(
                        icon: Icon(Icons.build_rounded),
                        iconAlignment: IconAlignment.end,
                        label: Text("Reset"),
                        onPressed: () async {
                            await loadStories();
                            await settings.reset();
                        }
                    )
            )
          ],
        )
    );


  }
}