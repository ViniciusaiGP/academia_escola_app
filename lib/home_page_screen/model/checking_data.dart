class CheckingData {
  final DateTime data;
  final int quantidade;

  CheckingData({
    required this.data,
    required this.quantidade,
  });

  // Método para criar uma instância de CheckingData a partir de um mapa JSON
  factory CheckingData.fromJson(Map<String, dynamic> json) {
    return CheckingData(
      data: DateTime.parse(json['data'] as String),
      quantidade: json['quantidade'] as int,
    );
  }

  // Método para converter uma instância de CheckingData em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.toIso8601String(),
      'quantidade': quantidade,
    };
  }
}
