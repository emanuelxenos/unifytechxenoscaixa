import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final AudioPlayer _finishPlayer = AudioPlayer();

  /// Toca o som de sucesso (Bip)
  Future<void> playSuccess() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/beep.mp3'));
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Toca o som de venda finalizada com sucesso
  Future<void> playSuccessSale() async {
    try {
      await _finishPlayer.stop();
      await _finishPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (_) {
      // Fallback
    }
  }

  /// Toca o som de erro
  Future<void> playError() async {
    try {
      await _errorPlayer.stop();
      await _errorPlayer.play(AssetSource('sounds/error.mp3'));
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void dispose() {
    _player.dispose();
    _errorPlayer.dispose();
    _finishPlayer.dispose();
  }
}
