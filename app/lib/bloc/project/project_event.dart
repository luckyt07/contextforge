part of 'project_bloc.dart';

sealed class ProjectEvent {}

final class GetProjectEvent extends ProjectEvent {
  GetProjectEvent();
}

final class CreateProjectEvent extends ProjectEvent {
  CreateProjectEvent({
    required this.projectName,
    required this.projectInstruction,
    required this.filePath,
  });

  final String projectName;
  final String projectInstruction;
  final String filePath;
}

final class DismissProjectCreationStatusEvent extends ProjectEvent {}

final class UpdateProjectEvent extends ProjectEvent {
  UpdateProjectEvent({
    required this.projectId,
    required this.projectName,
    required this.projectInstruction,
  });

  final String projectId;
  final String projectName;
  final String projectInstruction;
}

final class DeleteProjectEvent extends ProjectEvent {
  DeleteProjectEvent(this.projectId);

  final String projectId;
}
