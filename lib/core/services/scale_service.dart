import 'package:unifytechxenoscaixa/domain/models/product.dart';

class ScaleBarcodeResult {
  final String searchCode;
  final double value; // Pode ser preço total ou peso
  final bool isPrice; // Se o valor extraído é preço ou peso

  ScaleBarcodeResult({
    required this.searchCode,
    required this.value,
    this.isPrice = true,
  });
}

class ScaleService {
  /// Verifica se o código de barras é de balança (Padrão EAN-13 iniciando com 2)
  bool isScaleBarcode(String code) {
    // Remove espaços e caracteres não numéricos
    final cleanCode = code.replaceAll(RegExp(r'\D'), '');
    return cleanCode.startsWith('2') && cleanCode.length == 13;
  }

  /// Extrai as informações do código de barras da balança
  /// Padrão comum: [2][CCCCC][TTTTT][D]
  /// [2] = Identificador (1 dígito)
  /// [CCCCC] = Código do produto (6 dígitos considerando o prefixo 2)
  /// [TTTTT] = Valor Total ou Peso (5 dígitos)
  /// [D] = Dígito verificador (1 dígito)
  ScaleBarcodeResult? parseBarcode(String code) {
    if (!isScaleBarcode(code)) return null;

    // Extrai o identificador interno (Código do Produto - 5 dígitos)
    // No código 2 00123 00050 4, pegamos o "00123"
    final searchCode = code.substring(1, 6);

    // Extrai o valor (Dígitos 8 a 12)
    final valueStr = code.substring(7, 12);
    final value = double.tryParse(valueStr) ?? 0;

    // Lógica: Se o 7º dígito for 0, geralmente é Preço. Se for outro, pode ser Peso.
    // Mas para simplificar, vamos tratar como Valor Total (R$) dividido por 100.
    // R$ 00550 -> 5.50
    return ScaleBarcodeResult(
      searchCode: searchCode,
      value: value / 100, 
      isPrice: true,
    );
  }

  /// Calcula a quantidade baseada no preço unitário do produto
  double calculateQuantity(double totalPrice, double unitPrice) {
    if (unitPrice <= 0) return 0;
    // Retorna com 3 casas decimais (padrão de peso)
    return double.parse((totalPrice / unitPrice).toStringAsFixed(3));
  }
}
