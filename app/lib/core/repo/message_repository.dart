import 'dart:convert';

import 'package:ai_assistant_app/api_endpoints.dart';
import 'package:ai_assistant_app/core/network/api_service.dart';
import 'package:dio/dio.dart';

class MessageRepository {
  final ApiService apiService;

  MessageRepository(this.apiService);

  /// Streams custom events emitted by FastAPI's `/generate/text` endpoint.
  Stream<String> sendPrompt({
    required String prompt,
    required String projectId,
    String? conversationId,
  }) async* {
    final response = await apiService.get(
      ApiEndPoints.generateTextUrl,
      queryParameters: {
        'prompt': prompt,
        'project_id': projectId,
        if (conversationId != null) 'conversation_id': conversationId,
      },
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': "text/event-stream"},
      ),
    );

    final stream = (response.data! as ResponseBody).stream;
    yield* utf8.decoder.bind(stream);
  }

  Future<List<Map<String, dynamic>>> getHistory(String conversationId) async {
    final response = await apiService.get(
      '${ApiEndPoints.getProjectConversations}$conversationId',
    );
    final data = response.data;
    final messages = data is List
        ? data
        : data is Map<String, dynamic>
        ? data['messages'] as List<dynamic>? ?? const []
        : const [];

    return messages
        .whereType<Map>()
        .map((message) => Map<String, dynamic>.from(message))
        .toList();
  }
}
