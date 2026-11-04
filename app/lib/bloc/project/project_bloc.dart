import 'package:ai_assistant_app/core/models/response/project_model.dart';
import 'package:ai_assistant_app/core/repo/project_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'project_event.dart';

part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(this.repository) : super(ProjectState()) {
    on<GetProjectEvent>(onGetProjectEvents);
    on<CreateProjectEvent>(onCreateProject);
    on<UpdateProjectEvent>(onUpdateProject);
    on<DeleteProjectEvent>(onDeleteProject);
    on<DismissProjectCreationStatusEvent>(onDismissProjectCreationStatus);
  }

  Future<void> onUpdateProject(
    UpdateProjectEvent event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(isMutating: true, clearError: true));
    try {
      final updated = await repository.updateProject(
        projectId: event.projectId,
        projectName: event.projectName,
        projectInstruction: event.projectInstruction,
      );
      final projects = state.projects.map((project) {
        if (project.id != updated.id) return project;
        // The update endpoint does not include list-only aggregate fields.
        return updated.copyWith(
          conversationCount: project.conversationCount,
          createdAt: project.createdAt,
        );
      }).toList();
      emit(state.copyWith(projects: projects, isMutating: false));
    } catch (error) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> onDeleteProject(
    DeleteProjectEvent event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(isMutating: true, clearError: true));
    try {
      await repository.deleteProject(event.projectId);
      emit(
        state.copyWith(
          projects: state.projects
              .where((project) => project.id != event.projectId)
              .toList(),
          isMutating: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  final ProjectRepository repository;

  Future<void> onGetProjectEvents(
    GetProjectEvent event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final projects = await repository.getProjects();
      emit(state.copyWith(projects: projects, isLoading: false));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> onCreateProject(
    CreateProjectEvent event,
    Emitter<ProjectState> emit,
  ) async {
    if (state.isCreating) return;

    emit(
      state.copyWith(
        isCreating: true,
        creationStep: 'starting',
        creationMessage: 'Creating project…',
        creationProgress: 0,
        creationCompleted: false,
        clearError: true,
      ),
    );
    try {
      await for (final update in repository.createProject(
        projectName: event.projectName,
        projectInstruction: event.projectInstruction,
        filePath: event.filePath,
      )) {
        emit(
          state.copyWith(
            isCreating: update.status == 'running',
            creationStep: update.step,
            creationMessage: update.message,
            creationProgress: update.progress,
            creationCompleted: update.status == 'completed',
          ),
        );
      }
      if (!state.creationCompleted) {
        throw StateError('Project creation ended before it completed.');
      }
    } catch (error) {
      emit(
        state.copyWith(
          isCreating: false,
          creationStep: 'failed',
          creationMessage: error.toString().replaceFirst('Exception: ', ''),
          clearError: true,
        ),
      );
      return;
    }

    // A refresh failure must not change a successfully completed creation into
    // an error. The project remains available after the next normal refresh.
    try {
      final projects = await repository.getProjects();
      emit(state.copyWith(projects: projects));
    } catch (_) {}
  }

  void onDismissProjectCreationStatus(
    DismissProjectCreationStatusEvent event,
    Emitter<ProjectState> emit,
  ) {
    if (!state.isCreating) {
      emit(state.copyWith(clearCreationStatus: true));
    }
  }
}
