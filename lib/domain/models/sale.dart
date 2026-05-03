class Sale {
  final int id;
  final String numeroVenda;
  final DateTime dataVenda;
  final double valorTotal;
  final double valorTroco;
  final String status;
  final String? operadorNome;
  final List<SaleItem> itens;
  final List<SalePayment> pagamentos;

  Sale({
    required this.id,
    required this.numeroVenda,
    required this.dataVenda,
    required this.valorTotal,
    this.valorTroco = 0,
    this.status = 'finalizada',
    this.operadorNome,
    this.itens = const [],
    this.pagamentos = const [],
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id_venda'] ?? 0,
      numeroVenda: json['numero_venda'] ?? '',
      dataVenda: DateTime.tryParse(json['data_venda'] ?? '') ?? DateTime.now(),
      valorTotal: (json['valor_total'] ?? 0).toDouble(),
      valorTroco: (json['valor_troco'] ?? 0).toDouble(),
      status: json['status'] ?? 'finalizada',
      operadorNome: json['operador_nome'],
      itens: (json['itens'] as List?)?.map((e) => SaleItem.fromJson(e)).toList() ?? [],
      pagamentos: (json['pagamentos'] as List?)?.map((e) => SalePayment.fromJson(e)).toList() ?? [],
    );
  }
}

class SaleItem {
  final int id;
  final int produtoId;
  final int sequencia;
  final double quantidade;
  final String unidadeVenda;
  final double precoUnitario;
  final double valorTotal;
  final double valorDesconto;
  final double valorLiquido;
  final String status;
  final String? produtoNome;

  SaleItem({
    required this.id,
    required this.produtoId,
    required this.sequencia,
    required this.quantidade,
    this.unidadeVenda = 'UN',
    required this.precoUnitario,
    required this.valorTotal,
    this.valorDesconto = 0,
    required this.valorLiquido,
    this.status = 'vendido',
    this.produtoNome,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id_item_venda'] ?? 0,
      produtoId: json['produto_id'] ?? 0,
      sequencia: json['sequencia'] ?? 0,
      quantidade: (json['quantidade'] ?? 0).toDouble(),
      unidadeVenda: json['unidade_venda'] ?? 'UN',
      precoUnitario: (json['preco_unitario'] ?? 0).toDouble(),
      valorTotal: (json['valor_total'] ?? 0).toDouble(),
      valorDesconto: (json['valor_desconto'] ?? 0).toDouble(),
      valorLiquido: (json['valor_liquido'] ?? 0).toDouble(),
      status: json['status'] ?? 'vendido',
      produtoNome: json['produto_nome'],
    );
  }
}

class SalePayment {
  final int id;
  final int formaPagamentoId;
  final double valor;
  final double trocoPara;
  final int parcelas;
  final String status;
  final String? formaPagamentoNome;

  SalePayment({
    required this.id,
    required this.formaPagamentoId,
    required this.valor,
    this.trocoPara = 0,
    this.parcelas = 1,
    this.status = 'aprovado',
    this.formaPagamentoNome,
  });

  factory SalePayment.fromJson(Map<String, dynamic> json) {
    return SalePayment(
      id: json['id_venda_pagamento'] ?? 0,
      formaPagamentoId: json['forma_pagamento_id'] ?? 0,
      valor: (json['valor'] ?? 0).toDouble(),
      trocoPara: (json['troco_para'] ?? 0).toDouble(),
      parcelas: json['parcelas'] ?? 1,
      status: json['status'] ?? 'aprovado',
      formaPagamentoNome: json['forma_pagamento_nome'],
    );
  }
}

// ─── Request Models ───────────────────────────────────────────

class CreateSaleRequest {
  final int? clienteId;
  final List<CreateSaleItemRequest> itens;
  final List<CreatePaymentRequest> pagamentos;
  final String? observacoes;

  CreateSaleRequest({this.clienteId, required this.itens, required this.pagamentos, this.observacoes});

  Map<String, dynamic> toJson() => {
    if (clienteId != null) 'cliente_id': clienteId,
    'itens': itens.map((e) => e.toJson()).toList(),
    'pagamentos': pagamentos.map((e) => e.toJson()).toList(),
    if (observacoes != null) 'observacoes': observacoes,
  };
}

class CreateSaleItemRequest {
  final int produtoId;
  final double quantidade;
  final double precoUnitario;
  final double valorDesconto;

  CreateSaleItemRequest({
    required this.produtoId, required this.quantidade,
    required this.precoUnitario, this.valorDesconto = 0,
  });

  Map<String, dynamic> toJson() => {
    'produto_id': produtoId, 'quantidade': quantidade,
    'preco_unitario': precoUnitario, 'valor_desconto': valorDesconto,
  };
}

class CreatePaymentRequest {
  final int formaPagamentoId;
  final double valor;
  final int parcelas;
  final String? autorizacao;

  CreatePaymentRequest({
    required this.formaPagamentoId, required this.valor,
    this.parcelas = 1, this.autorizacao,
  });

  Map<String, dynamic> toJson() => {
    'forma_pagamento_id': formaPagamentoId, 'valor': valor,
    'parcelas': parcelas,
    if (autorizacao != null) 'autorizacao': autorizacao,
  };
}

class CancelSaleRequest {
  final String motivo;
  final String senhaSupervisor;

  CancelSaleRequest({required this.motivo, required this.senhaSupervisor});

  Map<String, dynamic> toJson() => {'motivo': motivo, 'senha_supervisor': senhaSupervisor};
}

class SaleResponse {
  final int idVenda;
  final String numeroVenda;
  final double valorTotal;
  final double valorTroco;
  final String? comprovante;

  SaleResponse({
    required this.idVenda,
    required this.numeroVenda,
    required this.valorTotal,
    this.valorTroco = 0,
    this.comprovante,
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      idVenda: json['id_venda'] ?? 0,
      numeroVenda: json['numero_venda'] ?? '',
      valorTotal: (json['valor_total'] ?? 0).toDouble(),
      valorTroco: (json['valor_troco'] ?? 0).toDouble(),
      comprovante: json['comprovante'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleResponse &&
          runtimeType == other.runtimeType &&
          idVenda == other.idVenda &&
          numeroVenda == other.numeroVenda;

  @override
  int get hashCode => idVenda.hashCode ^ numeroVenda.hashCode;
}

// ─── Cart Item (local) ────────────────────────────────────────

class CartItem {
  final int produtoId;
  final String produtoNome;
  final String? produtoFotoUrl;
  final String unidadeVenda;
  final double precoUnitario;
  double quantidade;
  double desconto;

  CartItem({
    required this.produtoId,
    required this.produtoNome,
    this.produtoFotoUrl,
    this.unidadeVenda = 'UN',
    required this.precoUnitario,
    this.quantidade = 1,
    this.desconto = 0,
  });

  double get subtotal => precoUnitario * quantidade;
  double get total => subtotal - desconto;
}
