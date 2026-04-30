class Product {
  final int id;
  final String? codigoBarras;
  final String nome;
  final double precoVenda;
  final double estoqueAtual;
  final String unidadeVenda;
  final String? fotoUrl;
  final String? categoriaNome;
  final double? precoPromocional;
  final bool controlarEstoque;

  Product({
    required this.id,
    this.codigoBarras,
    required this.nome,
    required this.precoVenda,
    required this.estoqueAtual,
    this.unidadeVenda = 'UN',
    this.fotoUrl,
    this.categoriaNome,
    this.precoPromocional,
    this.controlarEstoque = true,
  });

  /// Preço efetivo (promocional se disponível)
  double get precoEfetivo => precoPromocional ?? precoVenda;

  /// Se está em promoção
  bool get emPromocao => precoPromocional != null && precoPromocional! < precoVenda;

  /// Se tem estoque disponível
  bool get temEstoque => !controlarEstoque || estoqueAtual > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id_produto'] ?? 0,
      codigoBarras: json['codigo_barras'],
      nome: json['nome'] ?? '',
      precoVenda: (json['preco_venda'] ?? 0).toDouble(),
      estoqueAtual: (json['estoque_atual'] ?? 0).toDouble(),
      unidadeVenda: json['unidade_venda'] ?? 'UN',
      fotoUrl: json['foto_principal_url'],
      categoriaNome: json['categoria_nome'],
      precoPromocional: json['preco_promocional'] != null
          ? (json['preco_promocional']).toDouble() : null,
      controlarEstoque: json['controlar_estoque'] ?? true,
    );
  }
}

/// Resultado de busca simplificado
class ProductSearchResult {
  final int id;
  final String? codigoBarras;
  final String nome;
  final double precoVenda;
  final double estoqueAtual;
  final String unidadeVenda;

  ProductSearchResult({
    required this.id,
    this.codigoBarras,
    required this.nome,
    required this.precoVenda,
    required this.estoqueAtual,
    this.unidadeVenda = 'UN',
  });

  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    return ProductSearchResult(
      id: json['id_produto'] ?? 0,
      codigoBarras: json['codigo_barras'],
      nome: json['nome'] ?? '',
      precoVenda: (json['preco_venda'] ?? 0).toDouble(),
      estoqueAtual: (json['estoque_atual'] ?? 0).toDouble(),
      unidadeVenda: json['unidade_venda'] ?? 'UN',
    );
  }
}
