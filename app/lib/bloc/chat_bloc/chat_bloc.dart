import 'package:ai_assistant_app/core/repo/message_repository.dart';
import 'package:ai_assistant_app/model/message_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this.repo) : super(const ChatState()) {
    on<ChatSendEvent>(_onChatSent);
    on<ChatHistoryEvent>(_onChatHistoryEvent);
  }

  final MessageRepository repo;

  Future<void> _onChatSent(ChatSendEvent event, Emitter<ChatState> emit) async {
    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          MessageModel(message: event.prompt, isUser: true),
        ],
        status: ChatStatus.streaming,
        activeNode: 'query_rewriting',
        clearError: true,
      ),
    );

    var buffer = '';
    try {
      await for (final chunk in repo.sendPrompt(
        prompt: event.prompt,
        projectId: event.projectId,
        conversationId: event.conversationId,
      )) {
        buffer += chunk;
        final result = _readEvents(buffer);
        buffer = result.remaining;

        for (final streamEvent in result.events) {
          if (streamEvent.type == 'END') continue;

          final isContent = streamEvent.type == 'CONTENT';
          final lastMessage = state.messages.isNotEmpty
              ? state.messages.last
              : null;
          final nextMessage = lastMessage != null && !lastMessage.isUser
              ? lastMessage.copyWith(
                  message: isContent ? streamEvent.value : '',
                  reasoning: isContent ? '' : streamEvent.value,
                )
              : MessageModel(
                  message: isContent ? streamEvent.value : '',
                  reasoning: isContent ? '' : streamEvent.value,
                );
          final messages = lastMessage != null && !lastMessage.isUser
              ? [
                  ...state.messages.sublist(0, state.messages.length - 1),
                  nextMessage,
                ]
              : [...state.messages, nextMessage];

          emit(
            state.copyWith(
              messages: messages,
              activeNode: isContent ? 'llm_call' : 'llm_reasoning',
            ),
          );
        }
      }
      emit(state.copyWith(status: ChatStatus.idle, clearActiveNode: true));
    } catch (error) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          clearActiveNode: true,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  _StreamReadResult _readEvents(String source) {
    final events = <_StreamEvent>[];
    var buffer = source;

    while (true) {
      final start = buffer.indexOf('<|');
      if (start < 0) {
        // Keep a possible split opening marker for the next network chunk.
        return _StreamReadResult(
          events,
          buffer.length > 20 ? buffer.substring(buffer.length - 20) : buffer,
        );
      }
      if (start > 0) buffer = buffer.substring(start);

      final typeEnd = buffer.indexOf('|>', 2);
      if (typeEnd < 0) return _StreamReadResult(events, buffer);
      final type = buffer.substring(2, typeEnd);
      final closingMarker = '<|$type|>';
      final valueStart = typeEnd + 2;
      final valueEnd = buffer.indexOf(closingMarker, valueStart);
      if (valueEnd < 0) return _StreamReadResult(events, buffer);

      events.add(_StreamEvent(type, buffer.substring(valueStart, valueEnd)));
      buffer = buffer.substring(valueEnd + closingMarker.length);
    }
  }

  Future<void> _onChatHistoryEvent(
    ChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final history = await repo.getHistory(event.convId);
      final messages = history
          .map(
            (message) => MessageModel(
              message: message['content']?.toString() ?? '',
              isUser: message['role'] == 'human' || message['role'] == 'user',
            ),
          )
          .where((message) => message.message.isNotEmpty)
          .toList();

      emit(state.copyWith(messages: messages, clearError: true));
    } catch (error) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}

class _StreamEvent {
  const _StreamEvent(this.type, this.value);

  final String type;
  final String value;
}

class _StreamReadResult {
  const _StreamReadResult(this.events, this.remaining);

  final List<_StreamEvent> events;
  final String remaining;
}
