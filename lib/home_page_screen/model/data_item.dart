class DataItem {
  final String curso;
  final String email;
  final String nome;
  final String ra;
  final List<String> datasMarcadas;

  DataItem({
    required this.curso,
    required this.email,
    required this.nome,
    required this.ra,
    required this.datasMarcadas,
  });

  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      curso: json['curso'] ?? '', // Usa uma string vazia se 'curso' for null
      email: json['email'] ?? '', // Usa uma string vazia se 'email' for null
      nome: json['nome'] ?? '', // Usa uma string vazia se 'nome' for null
      ra: json['ra'] ?? '', // Usa uma string vazia se 'ra' for null
      datasMarcadas: List<String>.from(
          json['datas_marcadas']), // Atualizando para refletir a nova estrutura
    );
  }
}
