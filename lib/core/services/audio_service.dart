import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  final SharedPreferences _prefs;
  final AudioPlayer _player = AudioPlayer();
  bool _isSoundEnabled = true;
  bool _isPlaying = false;

  AudioService(this._prefs) {
    _isSoundEnabled = _prefs.getBool('bg_sound_enabled') ?? true;
  }

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    try {
      await AudioPlayer.global.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.defaultToSpeaker,
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ));
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.5);
    } catch (_) {}
  }

  Future<void> playBackgroundSound() async {
    if (!_isSoundEnabled || _isPlaying) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.5);
      await _player.play(AssetSource('audio/background_ambient.mp3'));
      _isPlaying = true;
    } catch (_) {}
  }

  Future<void> stopBackgroundSound() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (_) {}
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    await _prefs.setBool('bg_sound_enabled', _isSoundEnabled);

    if (_isSoundEnabled) {
      await playBackgroundSound();
    } else {
      await stopBackgroundSound();
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    await _prefs.setBool('bg_sound_enabled', enabled);

    if (_isSoundEnabled) {
      await playBackgroundSound();
    } else {
      await stopBackgroundSound();
    }
  }
}
