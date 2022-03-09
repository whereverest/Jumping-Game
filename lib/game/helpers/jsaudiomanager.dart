import 'package:common/common.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers_api.dart';

class JSAudioManager {
  JSAudioManager({
    required this.gameUtil,
  }) : oncePlayed = false;

  final GameUtil gameUtil;
  late bool oncePlayed;
  FabAudioPlayer? audioPlayerSpeaking,
      audioPlayerUISound,
      backgroundMusicPlayer,
      audioPlayerCharacter;

  bool mutexForRightChoice = false;
  bool mutexForWrongChoice = false;
  bool shoutFlag = false;
  bool laughFlag = false;
  bool mutexForSayWordFlag = false;

  void clearOut() {
    stopBGM();
    audioPlayerUISound?.dispose();
    audioPlayerSpeaking?.dispose();
    backgroundMusicPlayer?.dispose();
    audioPlayerCharacter?.dispose();
  }

  void stopBGM() {
    backgroundMusicPlayer?.stop();
    audioPlayerSpeaking?.stop();
    audioPlayerUISound?.stop();
    audioPlayerCharacter?.stop();
  }

  void playBackgroundMusic({
    backgroundMusicUrl: "Background.mp3",
  }) async {
    backgroundMusicPlayer?.dispose();
    backgroundMusicPlayer = await gameUtil.audioManager.loop(
      "audio/" + backgroundMusicUrl,
    );
  }

  void playLaughAudio() async {
    try {
      if (!laughFlag) {
        laughFlag = true;
        audioPlayerCharacter?.dispose();
        audioPlayerCharacter = await gameUtil.audioManager.play(
          "audio/Laugh.mp3",
          volume: 1.0,
        );
        await audioPlayerCharacter?.waitFinish;
        await gameUtil.delayer.wait(seconds: 2);
        laughFlag = false;
      }
    } catch (_) {}
  }

  Future<void> playUISound(String fileName) async {
    try {
      audioPlayerUISound?.dispose();
      audioPlayerUISound = await gameUtil.audioManager.play(
        "audio/" + fileName,
        volume: 2.0,
      );
    } catch (_) {}
  }

  void shoutWJ(String fileName) async {
    try {
      if (!shoutFlag) {
        await gameUtil.audioManager.play("audio/" + fileName);
        shoutFlag = true;
        await gameUtil.delayer.wait(seconds: 6);
        shoutFlag = false;
      }
    } catch (_) {}
  }

  void stopUISound() {
    audioPlayerUISound?.stop();
  }

  void stopSpeaking() {
    audioPlayerSpeaking?.stop();
  }

  void sayWord(String character, String wordStructure) async {
    try {
      if (mutexForSayWordFlag == false) {
        await gameUtil.audioManager.play(
          "audio/" + "voice/" + character + "_" + wordStructure + ".mp3",
        );
        mutexForSayWordFlag = true;
        await gameUtil.delayer.wait(milliseconds: 400);
        mutexForSayWordFlag = false;
      }
    } catch (_) {}
  }

  FabAudioPlayer? _saySeparatedPlayer;

  void saySeparated(String character, String wordStructure) async {
    final _path =
        "audio/" + "separated/" + character + "_" + wordStructure + ".mp3";

    /// Small hack for prevent running same sounds in loop in Joi and Woof update methods.
    if (_saySeparatedPlayer?.path == _path) {
      return;
    }
    _saySeparatedPlayer = await gameUtil.audioManager.play(_path);
  }

  void sayRight(String character, String number) async {
    try {
      if (!mutexForRightChoice) {
        mutexForRightChoice = true;
        stopSpeaking();
        await gameUtil.audioManager.play(
          "audio/" + "match-right/" + character + "_" + number + ".mp3",
        );
        await gameUtil.delayer.wait(seconds: 1);
        mutexForRightChoice = false;
      } else {
        //print("[DEBUG] - Oops! Want to say right, but disabled");
      }
    } catch (_) {}
  }

  void sayWrong(String character, String number) async {
    try {
      if (!mutexForWrongChoice) {
        mutexForWrongChoice = true;
        stopSpeaking();
        await gameUtil.audioManager.play(
          "audio/" + "match-wrong/" + character + "_W(" + number + ").mp3",
        );
        await gameUtil.delayer.wait(seconds: 1);
        mutexForWrongChoice = false;
      } else {}
    } catch (_) {}
  }

  void speak(String character, String fileName) async {
    if (oncePlayed) return;
    print("[DEBUG] - audio repeated");
    oncePlayed = true;
    audioPlayerSpeaking?.dispose();
    audioPlayerSpeaking =
        await gameUtil.audioManager.play("audio/" + character + "_" + fileName);
  }

  bool checkFinished() {
    if (audioPlayerSpeaking?.state == PlayerState.COMPLETED ||
        audioPlayerSpeaking?.state == PlayerState.STOPPED) {
      oncePlayed = false;
      return true;
    }
    return false;
  }
}
