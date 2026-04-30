class CashSession {
  final int id;
  final int caixaFisicoId;
  final int usuarioId;
  final String codigoSessao;
  final DateTime dataAbertura;
  final DateTime? dataFechamento;
  final double saldoInicial;
  final double totalVendas;
  final double totalVendasCanceladas;
  final double totalDescontosConcedidos;
  final double totalSangrias;
  final double totalSuprimentos;
  final double totalDinheiro;
  final double totalCartaoDebito;
  final double totalCartaoCredito;
  final double totalPix;
  final double totalVale;
  final double totalOutros;
  final double saldoFinal;
  final double saldoFinalEsperado;
  final double diferenca;
  final String status;

  CashSession({
    required this.id,
    required this.caixaFisicoId,
    required this.usuarioId,
    required this.codigoSessao,
    required this.dataAbertura,
    this.dataFechamento,
    this.saldoInicial = 0,
    this.totalVendas = 0,
    this.totalVendasCanceladas = 0,
    this.totalDescontosConcedidos = 0,
    this.totalSangrias = 0,
    this.totalSuprimentos = 0,
    this.totalDinheiro = 0,
    this.totalCartaoDebito = 0,
    this.totalCartaoCredito = 0,
    this.totalPix = 0,
    this.totalVale = 0,
    this.totalOutros = 0,
    this.saldoFinal = 0,
    this.saldoFinalEsperado = 0,
    this.diferenca = 0,
    this.status = 'aberto',
  });

  bool get isAberto => status == 'aberto';

  factory CashSession.fromJson(Map<String, dynamic> json) {
    return CashSession(
      id: json['id_sessao'] ?? 0,
      caixaFisicoId: json['caixa_fisico_id'] ?? 0,
      usuarioId: json['usuario_id'] ?? 0,
      codigoSessao: json['codigo_sessao'] ?? '',
      dataAbertura: DateTime.tryParse(json['data_abertura'] ?? '') ?? DateTime.now(),
      dataFechamento: json['data_fechamento'] != null ? DateTime.tryParse(json['data_fechamento']) : null,
      saldoInicial: (json['saldo_inicial'] ?? 0).toDouble(),
      totalVendas: (json['total_vendas'] ?? 0).toDouble(),
      totalVendasCanceladas: (json['total_vendas_canceladas'] ?? 0).toDouble(),
      totalDescontosConcedidos: (json['total_descontos_concedidos'] ?? 0).toDouble(),
      totalSangrias: (json['total_sangrias'] ?? 0).toDouble(),
      totalSuprimentos: (json['total_suprimentos'] ?? 0).toDouble(),
      totalDinheiro: (json['total_dinheiro'] ?? 0).toDouble(),
      totalCartaoDebito: (json['total_cartao_debito'] ?? 0).toDouble(),
      totalCartaoCredito: (json['total_cartao_credito'] ?? 0).toDouble(),
      totalPix: (json['total_pix'] ?? 0).toDouble(),
      totalVale: (json['total_vale'] ?? 0).toDouble(),
      totalOutros: (json['total_outros'] ?? 0).toDouble(),
      saldoFinal: (json['saldo_final'] ?? 0).toDouble(),
      saldoFinalEsperado: (json['saldo_final_esperado'] ?? 0).toDouble(),
      diferenca: (json['diferenca'] ?? 0).toDouble(),
      status: json['status'] ?? 'aberto',
    );
  }
}

class CashStatusResponse {
  final bool sessaoAtiva;
  final CashSession? sessao;
  final OperadorInfo? operador;

  CashStatusResponse({this.sessaoAtiva = false, this.sessao, this.operador});

  factory CashStatusResponse.fromJson(Map<String, dynamic> json) {
    return CashStatusResponse(
      sessaoAtiva: json['sessao_ativa'] ?? false,
      sessao: json['sessao'] != null ? CashSession.fromJson(json['sessao']) : null,
      operador: json['operador'] != null ? OperadorInfo.fromJson(json['operador']) : null,
    );
  }
}

class OperadorInfo {
  final int id;
  final String nome;

  OperadorInfo({required this.id, required this.nome});

  factory OperadorInfo.fromJson(Map<String, dynamic> json) {
    return OperadorInfo(id: json['id'] ?? 0, nome: json['nome'] ?? '');
  }
}

class OpenCashRequest {
  final int caixaFisicoId;
  final double saldoInicial;
  final String observacao;

  OpenCashRequest({required this.caixaFisicoId, required this.saldoInicial, this.observacao = ''});

  Map<String, dynamic> toJson() => {
    'caixa_fisico_id': caixaFisicoId, 'saldo_inicial': saldoInicial, 'observacao': observacao,
  };
}

class CloseCashRequest {
  final double saldoFinal;
  final String supervisorSenha;
  final String observacao;

  CloseCashRequest({required this.saldoFinal, required this.supervisorSenha, this.observacao = ''});

  Map<String, dynamic> toJson() => {
    'saldo_final': saldoFinal, 'supervisor_senha': supervisorSenha, 'observacao': observacao,
  };
}

class CashMovementRequest {
  final double valor;
  final String motivo;

  CashMovementRequest({required this.valor, required this.motivo});

  Map<String, dynamic> toJson() => {'valor': valor, 'motivo': motivo};
}
