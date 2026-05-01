import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  /// Toca o som de sucesso (Bip)
  Future<void> playSuccess() async {
    try {
      // Tenta tocar o arquivo customizado
      await _player.play(AssetSource('sounds/beep.mp3'));
    } catch (_) {
      // Se falhar (arquivo não existe), toca o som padrão do sistema
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Toca o som de venda finalizada com sucesso
  Future<void> playSuccessSale() async {
    try {
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (_) {
      // Fallback
    }
  }

  /// Toca o som de erro
  Future<void> playError() async {
    try {
      await _player.play(AssetSource('sounds/error.mp3'));
    } catch (_) {
      // Som de alerta do sistema
      SystemSound.play(SystemSoundType.click);
    }
  }

  void dispose() {
    _player.dispose();
  }
}
