part of 'project_bloc.dart';

final class ProjectState extends Equatable {
  final List<ProjectModel> projects;
  final bool isSearching;
  final bool isCreating;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;
  final String? creationStep;
  final String? creationMessage;
  final int creationProgress;
  final bool creationCompleted;

  const ProjectState({
    this.projects = const [],
    this.isCreating = false,
    this.isSearching = false,
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
    this.creationStep,
    this.creationMessage,
    this.creationProgress = 0,
    this.creationCompleted = false,
  });

  ProjectState copyWith({
    List<ProjectModel>? projects,
    bool? isSearching,
    bool? isCreating,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    String? creationStep,
    String? creationMessage,
    int? creationProgress,
    bool? creationCompleted,
    bool clearError = false,
    bool clearCreationStatus = false,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      isSearching: isSearching ?? this.isSearching,
      isCreating: isCreating ?? this.isCreating,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      creationStep: clearCreationStatus
          ? null
          : creationStep ?? this.creationStep,
      creationMessage: clearCreationStatus
          ? null
          : creationMessage ?? this.creationMessage,
      creationProgress: clearCreationStatus
          ? 0
          : creationProgress ?? this.creationProgress,
      creationCompleted: clearCreationStatus
          ? false
          : creationCompleted ?? this.creationCompleted,
    );
  }

  @override
  List<Object?> get props => [
    projects,
    isSearching,
    isCreating,
    isLoading,
    isMutating,
    errorMessage,
    creationStep,
    creationMessage,
    creationProgress,
    creationCompleted,
  ];
}
