/// Modelo para armazenar temporariamente treinos quando estiver offline
class PendingWorkout {
  /// ID local do treino pendente
  final String id;
  
  /// Dados do treino em formato JSON
  final Map<String, dynamic> data;
  
  /// Data de criação do registro pendente
  final DateTime createdAt;
  
  /// Construtor
  PendingWorkout({
    required this.id,
    required this.data,
    required this.createdAt,
  });
  
  /// Converte a instância para um mapa JSON para armazenamento local
  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data,
    'created_at': createdAt.toIso8601String(),
  };
  
  /// Cria uma instância a partir de um mapa JSON
  factory PendingWorkout.fromJson(Map<String, dynamic> json) {
    return PendingWorkout(
      id: json['id'],
      data: json['data'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 