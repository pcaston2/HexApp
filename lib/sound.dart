part of 'main.dart';

enum audioSound {
  PANEL_SUCCESS,
  PANEL_FAILURE,
  TRACING_START,
  TRACING_END
}

Map<audioSound, String> audioFiles = {
  audioSound.PANEL_SUCCESS: 'panel_success.mp3',
  audioSound.PANEL_FAILURE: 'panel_failure.mp3',
  audioSound.TRACING_END: 'stop_tracing.mp3',
  audioSound.TRACING_START: 'activate.mp3',
};

class SoundPlayer {
  late AudioPlayer audioPlayer;
  late AudioCache audioCache;
  SoundPlayer() {
    //AudioPlayer.logEnabled = true;
    //if (kIsWeb) {
      audioPlayer = new AudioPlayer();
      audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    //} else {
    //  audioCache = new AudioCache();
    //  audioCache.loadAll(audioFiles.values.toList());
    //}
  }

  void play(audioSound sound) {
    String fileName = audioFiles[sound]!;
    //if (kIsWeb) {
    audioPlayer.play(AssetSource(fileName));
    //} else if (Platform.isWindows) {
    //  print('Should play $fileName');
    //} else {
    //  audioCache.play(fileName, mode: PlayerMode.LOW_LATENCY);
    //  audioCache.
    //}
  }
}

