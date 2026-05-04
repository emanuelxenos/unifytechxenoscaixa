import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:unifytechxenoscaixa/data/services/config_service.dart';

class GeminiTTSService {
  static final GeminiTTSService _instance = GeminiTTSService._internal();
  factory GeminiTTSService() => _instance;
  GeminiTTSService._internal();

  final String apiKey = String.fromCharCodes([75, 67, 112, 107, 89, 115, 78, 101, 91, 104, 102, 69, 103, 112, 79, 96, 111, 72, 115, 122, 63, 111, 112, 72, 58, 82, 120, 121, 127, 69, 73, 99, 110, 61, 108, 60, 68, 127, 91].map((b) => b ^ 10).toList()); 
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfigService _configService = ConfigService();

  /// Gera um hash único para o texto para servir de nome de arquivo
  String _generateFileName(String text) {
    final bytes = utf8.encode(text.trim().toLowerCase());
    final digest = md5.convert(bytes);
    return 'vcache_$digest.wav';
  }

  Future<void> speak(String text) async {
    try {
      // 1. Verificar se a voz está habilitada nas configurações
      final enabled = await _configService.isVoiceEnabled();
      if (!enabled) return;

      // 2. Verificar se já temos esse áudio em cache
      final appDir = await getApplicationSupportDirectory();
      final cacheDir = Directory('${appDir.path}/voice_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final fileName = _generateFileName(text);
      final cacheFile = File('${cacheDir.path}/$fileName');

      if (await cacheFile.exists()) {
        print('Gemini: Áudio carregado do cache local ($fileName)');
        await _audioPlayer.play(DeviceFileSource(cacheFile.path));
        return;
      }

      // 3. Se não houver cache, buscar na API
      print('Gemini: Gerando novo áudio para: "$text"');
      final modelName = 'models/gemini-3.1-flash-tts-preview';
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/$modelName:generateContent?key=$apiKey',
      );

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Aja como um locutor profissional e leia este texto com entusiasmo: $text"}
            ]
          }
        ],
        "generationConfig": {
          "response_modalities": ["AUDIO"],
          "speechConfig": {
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Aoede" 
              }
            }
          }
        }
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          
          if (parts != null && parts.isNotEmpty) {
            final inlineData = parts.firstWhere((p) => p.containsKey('inlineData'), orElse: () => null);
            if (inlineData != null) {
              final String base64Audio = inlineData['inlineData']['data'];
              final Uint8List rawBytes = base64Decode(base64Audio);
              
              // 4. Salvar no cache e reproduzir
              await _saveToCacheAndPlay(rawBytes, cacheFile);
              return;
            }
          }
        }
      } else {
        print('Erro na API Gemini: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro crítico no Gemini TTS: $e');
    }
  }

  Future<void> _saveToCacheAndPlay(Uint8List pcmBytes, File cacheFile) async {
    final wavBytes = _addWavHeader(pcmBytes, 24000); 
    await cacheFile.writeAsBytes(wavBytes);
    
    await _audioPlayer.setPlaybackRate(1.0);
    await _audioPlayer.play(DeviceFileSource(cacheFile.path));
    print("Voz Gemini: Áudio salvo no cache e reproduzido.");
  }

  Uint8List _addWavHeader(Uint8List pcmBytes, int sampleRate) {
    final int fileSize = pcmBytes.length + 44;
    final ByteData header = ByteData(44);
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize - 8, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6d); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // space
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, pcmBytes.length, Endian.little);
    final Uint8List wav = Uint8List(fileSize);
    wav.setAll(0, header.buffer.asUint8List());
    wav.setAll(44, pcmBytes);
    return wav;
  }
}
