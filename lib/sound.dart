part of 'main.dart';

enum audioSound {
  PANEL_SUCCESS,
  PANEL_FAILURE,
  TRACING_START,
  TRACING_END
}

Map<audioSound, String> audioFiles = {
  audioSound.PANEL_SUCCESS: 'Success.mp3',
  audioSound.PANEL_FAILURE: 'Fail.mp3',
  audioSound.TRACING_END: 'Abort.mp3',
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
    return;
    //if (kIsWeb) {
    try {
      audioPlayer.play(AssetSource(fileName));
    } catch (ex) {
      //TODO: Find out why sound fails to play
      print(ex);
    }
    //} else if (Platform.isWindows) {
    //  print('Should play $fileName');
    //} else {
    //  audioCache.play(fileName, mode: PlayerMode.LOW_LATENCY);
    //  audioCache.
    //}
  }
}

