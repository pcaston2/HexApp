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

  Future<void> _pushRandomPuzzle() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final Random random = Random();
    bool first = true;

    while (true) {
      // 1. Setup a fresh temporary board
      Board board = Board.named("Random Puzzle");
      board.guid = Guid.newGuid.value; // Ensure unique GUID for every puzzle
      
      // Determine board size with weights: Small(2): 60%, Medium(3): 30%, Large(4): 10%
      double rSize = random.nextDouble();
      if (rSize < 0.6) {
        board.size = 2;
      } else if (rSize < 0.9) {
        board.size = 3;
      } else {
        board.size = 4;
      }

      board.mode = BoardMode.play;
      
      // 2. Randomize settings
      GeneratorSettings genSettings = GeneratorSettings();
      Frequency randomFreq() => Frequency.values[random.nextInt(Frequency.values.length)];
      
      genSettings.dotFreq = randomFreq();
      genSettings.edgeFreq = randomFreq();
      genSettings.cornerFreq = randomFreq();
      genSettings.sequenceFreq = randomFreq();
      genSettings.breakFreq = randomFreq();
      genSettings.tightness = Tightness.values[random.nextInt(Tightness.values.length)];
      genSettings.startCount = TerminalCount.values[random.nextInt(TerminalCount.values.length)];
      genSettings.endCount = TerminalCount.values[random.nextInt(TerminalCount.values.length)];
      genSettings.trailLength = TrailLength.values[random.nextInt(TrailLength.values.length)];

      // 3. Generate
      messenger.showSnackBar(const SnackBar(content: Text("Generating random puzzle..."), duration: Duration(milliseconds: 500)));
      bool success = await BoardGenerator().generate(board, genSettings);
      if (!success) {
        // If generation failed all attempts, try again from the start of the while loop
        await Future.delayed(Duration(milliseconds: 100));
        continue;
      }

      // 4. Push view
      var result = await (first 
        ? navigator.push(SlideRoute(page: BoardView([board], 0, BoardFlow(), Story())))
        : navigator.pushReplacement(SlideRoute(page: BoardView([board], 0, BoardFlow(), Story()))));

      first = false;
      if (!mounted) return;
      
      if (result == true) {
        // "Next" was pressed, loop to generate a new one
        continue;
      } else {
        // "Back" or other exit, return to main menu
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle menuButtonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 56),
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 2,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey.shade50,
              Colors.blueGrey.shade200,
              Colors.blueGrey.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/thex-title-transparency.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 64),
                ElevatedButton.icon(
                  style: menuButtonStyle,
                  icon: const Icon(Icons.play_arrow_rounded),
                  iconAlignment: IconAlignment.end,
                  label: const Text("Play", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (settings.haptic) HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      SlideRoute(page: StorySelection()),
                    );
                  },
                ),
                const SizedBox(height: 38),
                ElevatedButton.icon(
                  style: menuButtonStyle,
                  icon: Icon((settings.sound ? Icons.volume_up_rounded : Icons.volume_mute_rounded)),
                  iconAlignment: IconAlignment.end,
                  onPressed: () {
                    if (settings.haptic) HapticFeedback.selectionClick();
                    setState(() {
                      settings.sound = !settings.sound;
                      if (!settings.isDeveloperUnlocked) {
                        _devClickCount++;
                        if (_devClickCount >= 10) {
                          settings.isDeveloperUnlocked = true;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("You are now a developer!")));
                        } else if (_devClickCount > 5) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("You are now ${10 - _devClickCount} steps away from being a developer."),
                                duration: const Duration(seconds: 1),
                              ));
                        }
                      }
                    });
                  },
                  label: Text(settings.sound ? "Sound" : "No Sound"),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: menuButtonStyle,
                  icon: Icon((settings.haptic ? Icons.vibration_rounded : Icons.phonelink_erase_rounded)),
                  iconAlignment: IconAlignment.end,
                  onPressed: () {
                    setState(() {
                      settings.haptic = !settings.haptic;
                      if (settings.haptic) HapticFeedback.mediumImpact();
                    });
                  },
                  label: Text(settings.haptic ? "Haptics" : "No Haptics"),
                ),
                if (settings.isDeveloperUnlocked) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: menuButtonStyle,
                    icon: Icon((settings.developer ? Icons.play_arrow_rounded : Icons.design_services_rounded)),
                    iconAlignment: IconAlignment.end,
                    label: Text(settings.developer ? "Play Mode" : "Design Mode"),
                    onPressed: () {
                      if (settings.haptic) HapticFeedback.mediumImpact();
                      setState(() {
                        settings.developer = !settings.developer;
                      });
                    },
                  ),
                ],
                if (settings.developer) ...[
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: menuButtonStyle,
                    icon: const Icon(Icons.casino_rounded),
                    iconAlignment: IconAlignment.end,
                    label: const Text("Random Puzzle"),
                    onPressed: () {
                      if (settings.haptic) HapticFeedback.mediumImpact();
                      _pushRandomPuzzle();
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: IconButton(
                          tooltip: "Export All",
                          icon: const Icon(Icons.download_rounded, color: Colors.white70),
                          onPressed: () {
                            if (settings.haptic) HapticFeedback.mediumImpact();
                            _exportAll();
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: "Clear Progress",
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Clear Progress?"),
                                content: const Text("This will erase all your solved puzzles. Are you sure?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      if (settings.haptic) HapticFeedback.heavyImpact();
                                      settings.clearComplete();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Progress cleared.")));
                                    },
                                    child: const Text("CLEAR", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: "Reset All",
                          icon: const Icon(Icons.build_rounded, color: Colors.white70),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Reset All?"),
                                content: const Text("This will reset ALL settings and progress. Are you sure?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      if (settings.haptic) HapticFeedback.heavyImpact();
                                      await settings.reset();
                                      await loadStories();
                                      setState(() {
                                        _devClickCount = 0;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("All settings and progress reset.")));
                                    },
                                    child: const Text("RESET", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
