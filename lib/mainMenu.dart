part of 'main.dart';

class MainMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainMenuWidget();

}


class MainMenuWidget extends State<MainMenu> {
  int _devClickCount = 0;
  Future<void> _exportAll() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      var settings = await Settings.getInstance();
      var workingDir = Directory(settings.storagePath);
      
      if (!await workingDir.exists()) {
        messenger.showSnackBar(SnackBar(content: Text("Storage directory not found.")));
        return;
      }

      List<FileSystemEntity> files = workingDir.listSync();
      var jhexFiles = files.where((entity) =>
          entity is File &&
          (entity.path.endsWith(".jhexboard") ||
              entity.path.endsWith(".jhexflow") ||
              entity.path.endsWith(".jhexstory"))).toList();

      if (jhexFiles.isEmpty) {
        messenger.showSnackBar(
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

      if (!mounted) return;

      if (Platform.isWindows) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Export As',
          fileName: 'thex_export.zip',
          type: FileType.custom,
          allowedExtensions: ['zip'],
        );

        if (outputFile != null) {
          await zipFile.copy(outputFile);
          messenger.showSnackBar(
              SnackBar(content: Text("Export saved to $outputFile")));
        }
      } else {
        await Share.shareXFiles(
          [XFile(zipPath, mimeType: 'application/zip')], 
          text: 'THEX Export'
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Export failed: $e")));
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
                  if (!settings.isDeveloperUnlocked) {
                    _devClickCount++;
                    if (_devClickCount >= 10) {
                      settings.isDeveloperUnlocked = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("You are now a developer!")));
                    } else if (_devClickCount > 5) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("You are now ${10 - _devClickCount} steps away from being a developer."),
                            duration: Duration(seconds: 1),
                          ));
                    }
                  }
                });
              },
              label: Text(settings.sound ? "Sound" : "No Sound"),
            ),
            Visibility(
              visible: settings.isDeveloperUnlocked,
              child: ElevatedButton.icon(
                  icon: Icon((settings.developer ? Icons.play_arrow_rounded : Icons.design_services_rounded)),
                  iconAlignment: IconAlignment.end,
                  label: Text(settings.developer ? "Switch to Play Mode" : "Switch to Design Mode"),
                  onPressed: () {
                    setState(() {
                      settings.developer = !settings.developer;
                    });
                  },
              ),
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
                      icon: Icon(Icons.delete_sweep_rounded),
                      iconAlignment: IconAlignment.end,
                      label: Text("Clear Progress"),
                      onPressed: () {
                        settings.clearComplete();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Progress cleared.")));
                      }
                  ),
                  ElevatedButton.icon(
                      icon: Icon(Icons.build_rounded),
                      iconAlignment: IconAlignment.end,
                      label: Text("Reset"),
                      onPressed: () async {
                        await settings.reset();
                        await loadStories();
                        setState(() {
                          _devClickCount = 0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("All settings and progress reset.")));
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