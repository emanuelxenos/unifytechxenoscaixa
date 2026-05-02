import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class GeminiTTSService {
  static final GeminiTTSService _instance = GeminiTTSService._internal();
  factory GeminiTTSService() => _instance;
  GeminiTTSService._internal();

  final String apiKey = 'AIzaSyBl2BCrC6hXezt6q3hIfY56phJbCKuVJmo'; 
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> speak(String text) async {
    try {
      // Usando o nome exato do modelo especializado em TTS da sua lista
      final modelName = 'models/gemini-3.1-flash-tts-preview';
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/$modelName:generateContent?key=$apiKey',
      );

      // Ajustando para o formato Multimodal REST que evita o erro 400
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Aja como um locutor profissional e leia este texto com entusiasmo: $text"}
            ]
          }
        ],
        "generationConfig": {
          // Usamos modalities para pedir áudio sem causar erro de MIME type
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
            // No modo AUDIO, o Gemini retorna inlineData com o áudio PCM
            final inlineData = parts.firstWhere((p) => p.containsKey('inlineData'), orElse: () => null);
            
            if (inlineData != null) {
              final String base64Audio = inlineData['inlineData']['data'];
              final Uint8List rawBytes = base64Decode(base64Audio);
              
              // Como não pedimos WAV via MIME, ele volta PCM bruto (precisa do Header)
              await _playWavAudio(rawBytes);
              return;
            }
          }
        }
        print('Gemini: Resposta recebida, mas sem dados de áudio.');
      } else {
        print('Erro na API Gemini: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro crítico no Gemini TTS: $e');
      rethrow;
    }
  }

  /// Converte PCM bruto (24kHz, 16-bit, Mono) para um arquivo .WAV tocável
  Future<void> _playWavAudio(Uint8List pcmBytes) async {
    final wavBytes = _addWavHeader(pcmBytes, 24000); 
    
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/gemini_final.wav');
    await file.writeAsBytes(wavBytes);
    
    await _audioPlayer.setPlaybackRate(1.0);
    await _audioPlayer.play(DeviceFileSource(file.path));
    print("Voz Gemini (Multimodal) executada com sucesso!");
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
