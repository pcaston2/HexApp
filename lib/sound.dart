part of 'main.dart';

enum audioSound {
  PANEL_SUCCESS,
  PANEL_FAILURE,
  TRACING_START,
  TRACING_END
}

Map <audioSound, AudioPlayer> audioPlayers = {
  audioSound.PANEL_SUCCESS: SoundPlayer.configureSound("Success.mp3"),
  audioSound.PANEL_FAILURE: SoundPlayer.configureSound("Fail.mp3"),
  audioSound.TRACING_END: SoundPlayer.configureSound("Abort.mp3"),
  audioSound.TRACING_START: SoundPlayer.configureSound("Activate.mp3"),
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

  static AudioPlayer configureSound(String assetName) {
    var player = AudioPlayer();
    player.setSourceAsset(assetName);
    player.setPlayerMode(PlayerMode.lowLatency);
    player.setReleaseMode(ReleaseMode.stop);
    return player;
  }

  void play(audioSound sound) {
    if (settings.sound) {
      var player = audioPlayers[sound]!;
      try {
        player.stop();
        player.resume();
      } catch (ex) {
        print(ex);
      }
    }
  }
}

