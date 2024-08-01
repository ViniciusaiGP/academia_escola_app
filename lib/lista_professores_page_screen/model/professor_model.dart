class ProfessorModel {
  final String dataInclusao;
  final String disciplina;
  final String email;
  final String nivelAcesso;
  final String nomeCompleto;

  ProfessorModel({
    required this.dataInclusao,
    required this.disciplina,
    required this.email,
    required this.nivelAcesso,
    required this.nomeCompleto,
  });

  // Construtor para converter um mapa em um objeto Professor
  factory ProfessorModel.fromJson(Map<String, dynamic> json) {
    return ProfessorModel(
      dataInclusao: json['data_inclusao'],
      disciplina: json['disciplina'],
      email: json['email'],
      nivelAcesso: json['nivel_acesso'],
      nomeCompleto: json['nomeCompleto'],
    );
  }
}
