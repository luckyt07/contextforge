class ProjectItem {
  final String id;
  final String title;
  final String description;
  final int documentCount;
  final int chatCount;
  final String updatedAt;
  final String category; // 'active', 'kb', 'personal'

  const ProjectItem({
    required this.id,
    required this.title,
    required this.description,
    required this.documentCount,
    required this.chatCount,
    required this.updatedAt,
    this.category = 'active',
  });
}
