import 'dart:convert';
import 'dart:io';

import 'package:ai_assistant_app/api_endpoints.dart';
import 'package:ai_assistant_app/core/models/response/project_model.dart';
import 'package:ai_assistant_app/core/models/response/project_conversation_model.dart';
import 'package:ai_assistant_app/core/network/api_service.dart';
import 'package:dio/dio.dart';

class ProjectCreationUpdate {
  const ProjectCreationUpdate({
    required this.status,
    required this.step,
    required this.message,
    required this.progress,
  });

  final String status;
  final String step;
  final String message;
  final int progress;

  factory ProjectCreationUpdate.fromJson(Map<String, dynamic> json) {
    return ProjectCreationUpdate(
      status: json['status'] as String? ?? 'running',
      step: json['step'] as String? ?? 'processing',
      message: json['message'] as String? ?? 'Creating project…',
      progress: (json['progress'] as num?)?.round() ?? 0,
    );
  }
}

class ProjectRepository {
  final ApiService apiService;

  ProjectRepository(this.apiService);

  Future<List<ProjectModel>> getProjects({int skip = 0, int take = 100}) async {
    final response = await apiService.get(
      ApiEndPoints.getProjects,
      queryParameters: {'skip': skip, 'take': take},
    );

    final List<dynamic> data = response.data as List<dynamic>;

    return data
        .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ProjectModel> updateProject({
    required String projectId,
    required String projectName,
    required String projectInstruction,
  }) async {
    final response = await apiService.put<Map<String, dynamic>>(
      '${ApiEndPoints.getProjects}$projectId',
      data: {
        'project_name': projectName,
        'project_instruction': projectInstruction,
      },
    );
    return ProjectModel.fromJson(response.data!);
  }

  Future<void> deleteProject(String projectId) async {
    await apiService.delete(
      ApiEndPoints.getProjects,
      queryParameters: {'id': projectId},
    );
  }

  Future<List<ProjectConversationModel>> getProjectConversations(
    String projectId,
  ) async {
    final response = await apiService.get(
      ApiEndPoints.getProjectConversations,
      queryParameters: {'project_id': projectId},
    );
    final data = response.data as List<dynamic>;
    return data
        .map(
          (json) =>
              ProjectConversationModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> deleteProjectConversation(String conversationId) async {
    await apiService.delete(
      ApiEndPoints.deleteProjectConversation,
      queryParameters: {'conversation_id': conversationId},
    );
  }

  Stream<ProjectCreationUpdate> createProject({
    required String projectName,
    required String projectInstruction,
    required String filePath,
  }) async* {
    final formData = FormData.fromMap({
      'project_name': projectName,
      'project_instruction': projectInstruction,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: File(filePath).uri.pathSegments.last,
      ),
    });
    final response = await apiService.post<ResponseBody>(
      ApiEndPoints.createProject,
      data: formData,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: Duration.zero,
        headers: const {'Accept': 'text/event-stream'},
      ),
    );
    final stream = response.data?.stream;
    if (stream == null) {
      throw StateError('Project creation did not return a progress stream.');
    }

    await for (final line
        in utf8.decoder.bind(stream).transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final raw = line.substring(5).trim();
      if (raw.isEmpty) continue;
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic> && json['event'] == 'project_creation') {
        yield ProjectCreationUpdate.fromJson(json);
      }
    }
  }

  // Stream<String> createProject(String prompt) async* {
  //   final response = await apiService.get(
  //     ApiEndPoints.generateTextUrl,
  //     queryParameters: {'prompt': prompt},
  //     options: Options(
  //       responseType: ResponseType.stream,
  //       headers: {'Accept': "text/event-stream"},
  //     ),
  //   );
  //
  //   final stream = (response.data! as ResponseBody).stream;
  //   await for (final bytes in stream) {
  //     final chunk = utf8.decode(bytes);
  //     yield chunk;
  //   }
  // }
}
