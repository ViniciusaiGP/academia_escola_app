class AlunoModel {
  final String curso;
  final String dataInclusao;
  final String dtNascimento;
  final String email;
  final String nivelAcesso;
  final String nomeCompleto;
  final String obs;
  final String ra;
  final String serie;
  final String telefone;

  AlunoModel({
    required this.curso,
    required this.dataInclusao,
    required this.dtNascimento,
    required this.email,
    required this.nivelAcesso,
    required this.nomeCompleto,
    required this.obs,
    required this.ra,
    required this.serie,
    required this.telefone,
  });

  // Construtor para converter um mapa em um objeto AlunoModel
  factory AlunoModel.fromJson(Map<String, dynamic> json) {
    return AlunoModel(
      curso: json['curso'],
      dataInclusao: json['data_inclusao'],
      dtNascimento: json['dtNascimento'],
      email: json['email'],
      nivelAcesso: json['nivel_acesso'],
      nomeCompleto: json['nomeCompleto'],
      obs: json['obs'],
      ra: json['ra'],
      serie: json['serie'],
      telefone: json['telefone'],
    );
  }
}