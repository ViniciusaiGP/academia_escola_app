class HourlyData {
  final String hora;
  final int quantidade;

  HourlyData({
    required this.hora,
    required this.quantidade,
  });

  // Método para criar uma instância de HourlyData a partir de um mapa JSON
  factory HourlyData.fromJson(Map<String, dynamic> json) {
    return HourlyData(
      hora: json['hora'] as String,
      quantidade: json['quantidade'] as int,
    );
  }

  // Método para converter uma instância de HourlyData em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'hora': hora,
      'quantidade': quantidade,
    };
  }
}
