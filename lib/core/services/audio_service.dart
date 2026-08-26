import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmbientTrack {
  final String id;
  final String title;
  final String description;
  final String assetName;
  final IconData icon;
  final String tag;

  const AmbientTrack({
    required this.id,
    required this.title,
    required this.description,
    required this.assetName,
    required this.icon,
    required this.tag,
  });
}

class AudioService {
  static const List<AmbientTrack> tracks = [
    AmbientTrack(
      id: 'zen_ambient',
      title: 'Zen Ambient',
      description: 'Gentle meditation drones & relaxing lo-fi frequencies',
      assetName: 'background_ambient.mp3',
      icon: Icons.spa_rounded,
      tag: 'CALM',
    ),
    AmbientTrack(
      id: 'deep_focus',
      title: 'Deep Focus',
      description: 'Warm acoustic piano & soothing major 7th harmony',
      assetName: 'deep_focus.mp3',
      icon: Icons.psychology_rounded,
      tag: 'FOCUS',
    ),
    AmbientTrack(
      id: 'cozy_rain',
      title: 'Cozy Rain',
      description: 'Soft raindrops paired with warm electric piano keys',
      assetName: 'cozy_rain.mp3',
      icon: Icons.water_drop_rounded,
      tag: 'COZY',
    ),
    AmbientTrack(
      id: 'cosmic_glow',
      title: 'Cosmic Glow',
      description: 'Ethereal ambient pads & peaceful celestial soundscapes',
      assetName: 'cosmic_glow.mp3',
      icon: Icons.auto_awesome_rounded,
      tag: 'DREAM',
    ),
    AmbientTrack(
      id: 'nature_serenity',
      title: 'Nature Serenity',
      description: 'Forest breeze, flowing stream & gentle acoustic chimes',
      assetName: 'nature_serenity.mp3',
      icon: Icons.forest_rounded,
      tag: 'NATURE',
    ),
  ];

  final SharedPreferences _prefs;
  final AudioPlayer _player = AudioPlayer();
  late final AppLifecycleListener _lifecycleListener;
  bool _isSoundEnabled = true;
  bool _isPlaying = false;
  String _currentTrackId = 'zen_ambient';
  final Map<String, String> _localTrackPaths = {};

  AudioService(this._prefs) {
    _isSoundEnabled = _prefs.getBool('bg_sound_enabled') ?? true;
    _currentTrackId = _prefs.getString('bg_sound_track_id') ?? 'zen_ambient';
    
    // Validate current track exists
    if (!tracks.any((t) => t.id == _currentTrackId)) {
      _currentTrackId = 'zen_ambient';
    }

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
  String get currentTrackId => _currentTrackId;

  AmbientTrack get currentTrack {
    return tracks.firstWhere(
      (t) => t.id == _currentTrackId,
      orElse: () => tracks.first,
    );
  }

  List<AmbientTrack> get availableTracks => tracks;

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

      // Pre-extract current track to local file cache
      await _extractTrack(_currentTrackId);
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
  }

  Future<String?> _extractTrack(String trackId) async {
    if (_localTrackPaths.containsKey(trackId)) {
      final existing = _localTrackPaths[trackId]!;
      if (await File(existing).exists()) return existing;
    }

    try {
      final track = tracks.firstWhere(
        (t) => t.id == trackId,
        orElse: () => tracks.first,
      );
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${track.assetName}');
      if (!await file.exists() || await file.length() == 0) {
        final byteData = await rootBundle.load('assets/audio/${track.assetName}');
        await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      }
      _localTrackPaths[trackId] = file.path;
      return file.path;
    } catch (e) {
      debugPrint('Error extracting track $trackId: $e');
      return null;
    }
  }

  Future<void> selectTrack(String trackId) async {
    if (_currentTrackId == trackId && _isPlaying) return;

    _currentTrackId = trackId;
    await _prefs.setString('bg_sound_track_id', trackId);

    if (_isSoundEnabled) {
      await playBackgroundSound();
    }
  }

  Future<void> playBackgroundSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);

      final localPath = await _extractTrack(_currentTrackId);
      if (localPath != null && await File(localPath).exists()) {
        await _player.play(DeviceFileSource(localPath));
        debugPrint('AudioService: playing $currentTrackId from DeviceFileSource ($localPath)');
      } else {
        final track = currentTrack;
        await _player.play(AssetSource('audio/${track.assetName}'));
        debugPrint('AudioService: playing $currentTrackId from AssetSource');
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
