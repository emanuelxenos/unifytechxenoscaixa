class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/api/login';
  static const String discover = '/api/discover';
  static const String health = '/health';

  // Caixa
  static const String caixaStatus = '/api/caixa/status';
  static const String caixaAbrir = '/api/caixa/abrir';
  static const String caixaFechar = '/api/caixa/fechar';
  static const String caixaSangria = '/api/caixa/sangria';
  static const String caixaSuprimento = '/api/caixa/suprimento';
  static const String caixaSessoes = '/api/caixa/sessoes';
  static const String caixaMovimentacoes = '/api/caixa/movimentacoes';
  static const String caixaFisicos = '/api/caixa/fisicos';

  // Vendas
  static const String vendas = '/api/vendas';
  static const String vendasDia = '/api/vendas/dia';
  static String vendaPorId(int id) => '/api/vendas/$id';
  static String vendaCancelar(int id) => '/api/vendas/$id/cancelar';

  // Produtos
  static const String produtos = '/api/produtos';
  static const String produtosBusca = '/api/produtos/busca';

  // Categorias
  static const String categorias = '/api/categorias';

  // WebSocket
  static const String ws = '/ws';
}
