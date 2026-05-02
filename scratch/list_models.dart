import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyBl2BCrC6hXezt6q3hIfY56phJbCKuVJmo';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');

  try {
    print('Buscando modelos disponíveis...');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = data['models'] as List;
      
      print('\nModelos encontrados:');
      for (var model in models) {
        final name = model['name'];
        final supportedMethods = model['supportedGenerationMethods'] as List;
        if (supportedMethods.contains('generateContent')) {
          print('- $name (Suporta generateContent)');
        }
      }
    } else {
      print('Erro ao listar modelos: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('Erro: $e');
  }
}
