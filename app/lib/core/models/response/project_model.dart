class ProjectModel {
  final String id;
  final String projectName;
  final String filename;
  final String instruction;
  final int conversationCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProjectModel({
    required this.id,
    required this.projectName,
    required this.filename,
    required this.instruction,
    this.conversationCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      // The current API returns an integer id and `project_instruction`.
      // Keep the legacy `desc` fallback so older API responses remain readable.
      id: json['id'].toString(),
      projectName: json['project_name'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      instruction:
          json['project_instruction'] as String? ??
          json['desc'] as String? ??
          '',
      conversationCount: (json['conversation_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_name': projectName,
      'filename': filename,
      'project_instruction': instruction,
      'conversation_count': conversationCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? projectName,
    String? filename,
    String? instruction,
    int? conversationCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      filename: filename ?? this.filename,
      instruction: instruction ?? this.instruction,
      conversationCount: conversationCount ?? this.conversationCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
