class User {
  final int id;
  final String nome;
  final String perfil;
  final UserPermissions permissoes;

  User({required this.id, required this.nome, required this.perfil, required this.permissoes});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      perfil: json['perfil'] ?? 'caixa',
      permissoes: UserPermissions.fromJson(json['permissoes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'nome': nome, 'perfil': perfil, 'permissoes': permissoes.toJson(),
  };
}

class UserPermissions {
  final bool podeAbrirCaixa;
  final bool podeDarDesconto;
  final double limiteDesconto;

  UserPermissions({
    this.podeAbrirCaixa = false,
    this.podeDarDesconto = false,
    this.limiteDesconto = 0,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      podeAbrirCaixa: json['pode_abrir_caixa'] ?? false,
      podeDarDesconto: json['pode_dar_desconto'] ?? false,
      limiteDesconto: (json['limite_desconto'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'pode_abrir_caixa': podeAbrirCaixa,
    'pode_dar_desconto': podeDarDesconto,
    'limite_desconto': limiteDesconto,
  };
}

class LoginRequest {
  final String login;
  final String senha;
  final String terminal;

  LoginRequest({required this.login, required this.senha, this.terminal = ''});

  Map<String, dynamic> toJson() => {'login': login, 'senha': senha, 'terminal': terminal};
}

class LoginResponse {
  final String token;
  final User usuario;

  LoginResponse({required this.token, required this.usuario});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      usuario: User.fromJson(json['usuario'] ?? {}),
    );
  }
}
