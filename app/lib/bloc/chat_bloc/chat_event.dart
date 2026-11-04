part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatSendEvent extends ChatEvent {
  final String prompt;
  final String projectId;
  final String? conversationId;

  const ChatSendEvent({
    required this.prompt,
    required this.projectId,
    this.conversationId,
  });

  @override
  List<Object?> get props => [prompt, projectId, conversationId];
}

final class ChatHistoryEvent extends ChatEvent {
  final String convId;

  const ChatHistoryEvent(this.convId);
}
