import 'package:flutter/services.dart';

abstract class SoundService {
  Future<void> playPopSound();
  Future<void> playClickSound();
}

class SoundServiceImpl implements SoundService {
  @override
  Future<void> playPopSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  @override
  Future<void> playClickSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }
}
