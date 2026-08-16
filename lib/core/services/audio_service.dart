import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  final SharedPreferences _prefs;
  final AudioPlayer _player = AudioPlayer();
  late final AppLifecycleListener _lifecycleListener;
  bool _isSoundEnabled = true;
  bool _isPlaying = false;
  String? _localAudioPath;

  AudioService(this._prefs) {
    _isSoundEnabled = _prefs.getBool('bg_sound_enabled') ?? true;
    _lifecycleListener = AppLifecycleListener(
      onPause: pauseBackgroundSound,
      onInactive: pauseBackgroundSound,
      onHide: pauseBackgroundSound,
      onResume: resumeBackgroundSound,
    );
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = (state == PlayerState.playing);
      debugPrint('AudioService PlayerState: $state');
    });
  }

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    try {
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: const AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);

      // Pre-extract asset to local file with proper .mp3 extension
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/background_ambient.mp3');
      if (!await file.exists() || await file.length() == 0) {
        final byteData = await rootBundle.load(
          'assets/audio/background_ambient.mp3',
        );
        await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      }
      _localAudioPath = file.path;
      debugPrint(
        'AudioService: initialized with local audio at $_localAudioPath',
      );
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
  }

  Future<void> playBackgroundSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);

      if (_localAudioPath != null && await File(_localAudioPath!).exists()) {
        await _player.play(DeviceFileSource(_localAudioPath!));
        debugPrint(
          'AudioService: playing from DeviceFileSource ($_localAudioPath)',
        );
      } else {
        await _player.play(AssetSource('audio/background_ambient.mp3'));
        debugPrint('AudioService: playing from AssetSource');
      }
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  Future<void> stopBackgroundSound() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> pauseBackgroundSound() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      }
    } catch (_) {}
  }

  Future<void> resumeBackgroundSound() async {
    if (!_isSoundEnabled) return;
    try {
      if (_player.state == PlayerState.paused) {
        await _player.resume();
      } else if (!_isPlaying) {
        await playBackgroundSound();
      }
    } catch (_) {
      await playBackgroundSound();
    }
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

  Future<void> dispose() async {
    try {
      _lifecycleListener.dispose();
      await _player.dispose();
    } catch (_) {}
  }
}
