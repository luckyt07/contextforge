class ProjectConversationModel {
  const ProjectConversationModel({
    required this.id,
    required this.projectId,
    required this.conversationId,
    required this.conversationTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int projectId;
  final String conversationId;
  final String conversationTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ProjectConversationModel.fromJson(Map<String, dynamic> json) {
    return ProjectConversationModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      conversationId: json['conversation_id'] as String,
      conversationTitle: json['conversation_title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
