part of 'main.dart';

class MainMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainMenuWidget();

}


class MainMenuWidget extends State<MainMenu> {
  Future<void> _exportAll() async {
    try {
      var settings = await Settings.getInstance();
      var workingDir = Directory(settings.storagePath);
      List<FileSystemEntity> files = workingDir.listSync();
      var jhexFiles = files.where((entity) =>
          entity is File &&
          (entity.path.endsWith(".jhexboard") ||
              entity.path.endsWith(".jhexflow") ||
              entity.path.endsWith(".jhexstory")));

      if (jhexFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No jhex files found to export.")));
        return;
      }

      var archive = Archive();
      for (var entity in jhexFiles) {
        var file = entity as File;
        var bytes = await file.readAsBytes();
        archive.addFile(
            ArchiveFile(p.basename(file.path), bytes.length, bytes));
      }

      var zipData = ZipEncoder().encode(archive);
      if (zipData == null) throw Exception("Failed to encode zip");

      final tempDir = await getTemporaryDirectory();
      final zipPath = '${tempDir.path}/thex_export.zip';
      File zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipData);

      await Share.shareXFiles([XFile(zipPath)], text: 'THEX Export');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Export failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Image.asset(
              'assets/thex-title-transparency.png',
              height: 40,
              fit: BoxFit.contain,
            ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                      icon: Icon(Icons.download_rounded),
                      iconAlignment: IconAlignment.end,
                      label: Text("Export All"),
                      onPressed: _exportAll
                  ),
                  ElevatedButton.icon(
                      icon: Icon(Icons.build_rounded),
                      iconAlignment: IconAlignment.end,
                      label: Text("Reset"),
                      onPressed: () async {
                        await loadStories();
                        await settings.reset();
                        setState(() {});
                      }
                  ),
                ],
              ),
            )
          ],
        )
    );


  }
}