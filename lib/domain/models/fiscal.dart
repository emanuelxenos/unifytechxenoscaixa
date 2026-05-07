class FiscalEmitirRequest {
  final int vendaId;

  FiscalEmitirRequest({required this.vendaId});

  Map<String, dynamic> toJson() => {
    'venda_id': vendaId,
  };
}

class FiscalEmitirResponse {
  final bool success;
  final String mensagem;
  final String? chaveAcesso;
  final String? arquivoPath;

  FiscalEmitirResponse({
    required this.success,
    required this.mensagem,
    this.chaveAcesso,
    this.arquivoPath,
  });

  factory FiscalEmitirResponse.fromJson(Map<String, dynamic> json) {
    return FiscalEmitirResponse(
      success: json['success'] ?? false,
      mensagem: json['mensagem'] ?? '',
      chaveAcesso: json['chave_acesso'],
      arquivoPath: json['arquivo_path'],
    );
  }
}
