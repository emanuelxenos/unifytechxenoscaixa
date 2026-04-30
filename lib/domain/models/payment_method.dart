class PaymentMethod {
  final int id;
  final String nome;
  final String codigo;
  final String tipo;
  final bool ativo;
  final bool exibirNoCaixa;
  final bool requerTroco;
  final double taxaOperacao;
  final int ordemExibicao;

  PaymentMethod({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.tipo,
    this.ativo = true,
    this.exibirNoCaixa = true,
    this.requerTroco = false,
    this.taxaOperacao = 0,
    this.ordemExibicao = 0,
  });

  /// Ícone baseado no tipo
  String get iconName {
    switch (tipo) {
      case 'dinheiro': return 'payments';
      case 'cartao_debito': return 'credit_card';
      case 'cartao_credito': return 'credit_score';
      case 'pix': return 'qr_code_2';
      case 'vale': return 'card_giftcard';
      default: return 'account_balance_wallet';
    }
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id_forma_pagamento'] ?? 0,
      nome: json['nome'] ?? '',
      codigo: json['codigo'] ?? '',
      tipo: json['tipo'] ?? '',
      ativo: json['ativo'] ?? true,
      exibirNoCaixa: json['exibir_no_caixa'] ?? true,
      requerTroco: json['requer_troco'] ?? false,
      taxaOperacao: (json['taxa_operacao'] ?? 0).toDouble(),
      ordemExibicao: json['ordem_exibicao'] ?? 0,
    );
  }
}
