part of 'main.dart';

enum audioSound {
  PANEL_SUCCESS,
  PANEL_FAILURE,
  TRACING_START,
  TRACING_END
}

Map <audioSound, String> audioFiles = {
  audioSound.PANEL_SUCCESS: "assets/Success.mp3",
  audioSound.PANEL_FAILURE: "assets/Fail.mp3",
  audioSound.TRACING_END: "assets/Abort.mp3",
  audioSound.TRACING_START: "assets/Activate.mp3",
};

class SoundPlayer {
  final Map<audioSound, AudioSource> _sources = {};

  SoundPlayer._internal(); // Private constructor

  static Future<SoundPlayer> create() async {
    var service = SoundPlayer._internal();
    try {
      await SoLoud.instance.init();
    } catch (e) {
      debugPrint("SoLoud initialization failed: $e");
    }
    await service.initSounds();
    return service;
  }

  void play(audioSound sound) {
    final source = _sources[sound];
    if (source != null) {
      SoLoud.instance.play(source);
    }
  }

  Future<void> initSounds () async {
    for (var entry in audioFiles.entries) {
      try {
        final source = await SoLoud.instance.loadAsset(entry.value);
        _sources[entry.key] = source;
      } catch (e) {
        debugPrint("Error loading sound ${entry.value}: $e");
      }
    }
  }

  void dispose() {
    SoLoud.instance.deinit();
  }
}
