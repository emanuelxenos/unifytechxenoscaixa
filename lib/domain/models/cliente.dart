class Cliente {
  final int id;
  final int empresaId;
  final String nome;
  final String tipoPessoa;
  final String? cpfCnpj;
  final String? telefone;
  final String? email;
  final double limiteCredito;
  final double saldoDevedor;
  final bool ativo;

  Cliente({
    required this.id,
    required this.empresaId,
    required this.nome,
    required this.tipoPessoa,
    this.cpfCnpj,
    this.telefone,
    this.email,
    required this.limiteCredito,
    required this.saldoDevedor,
    required this.ativo,
  });

  double get creditoDisponivel => limiteCredito - saldoDevedor;

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id_cliente'] ?? 0,
      empresaId: json['empresa_id'] ?? 0,
      nome: json['nome'] ?? '',
      tipoPessoa: json['tipo_pessoa'] ?? 'F',
      cpfCnpj: json['cpf_cnpj'],
      telefone: json['telefone'],
      email: json['email'],
      limiteCredito: (json['limite_credito'] as num?)?.toDouble() ?? 0.0,
      saldoDevedor: (json['saldo_devedor'] as num?)?.toDouble() ?? 0.0,
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cliente': id,
      'empresa_id': empresaId,
      'nome': nome,
      'tipo_pessoa': tipoPessoa,
      'cpf_cnpj': cpfCnpj,
      'telefone': telefone,
      'email': email,
      'limite_credito': limiteCredito,
      'saldo_devedor': saldoDevedor,
      'ativo': ativo,
    };
  }
}
