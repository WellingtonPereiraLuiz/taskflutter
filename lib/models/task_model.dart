/// Enum representando as categorias de tarefas disponíveis no GritTracker.
enum TaskCategory {
  treino,
  estudo,
  trabalho,
  outro;

  String get label {
    switch (this) {
      case TaskCategory.treino:
        return 'Treino';
      case TaskCategory.estudo:
        return 'Estudo';
      case TaskCategory.trabalho:
        return 'Trabalho';
      case TaskCategory.outro:
        return 'Outro';
    }
  }

  String get emoji {
    switch (this) {
      case TaskCategory.treino:
        return '💪';
      case TaskCategory.estudo:
        return '📚';
      case TaskCategory.trabalho:
        return '💼';
      case TaskCategory.outro:
        return '⚡';
    }
  }

  /// Cor temática de cada categoria (para a borda do card).
  int get colorValue {
    switch (this) {
      case TaskCategory.treino:
        return 0xFFFF6B35; // Laranja intenso
      case TaskCategory.estudo:
        return 0xFF00D4FF; // Cyan brilhante
      case TaskCategory.trabalho:
        return 0xFFAA66FF; // Roxo vibrante
      case TaskCategory.outro:
        return 0xFF39FF14; // Neon green (padrão)
    }
  }

  static TaskCategory fromString(String value) {
    return TaskCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskCategory.outro,
    );
  }
}

class TaskModel {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final TaskCategory category;

  const TaskModel({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.category = TaskCategory.outro,
  });

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    TaskCategory? category,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'category': category.name,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      category: map['category'] != null
          ? TaskCategory.fromString(map['category'] as String)
          : TaskCategory.outro,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, isCompleted: $isCompleted, category: ${category.name})';
  }
}
