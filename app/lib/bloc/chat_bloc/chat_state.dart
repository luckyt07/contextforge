part of 'chat_bloc.dart';

// sealed class ChatState extends Equatable {
//   const ChatState();
// }

enum ChatStatus {
  idle,
  streaming,
  failure;

  bool isStreaming() {
    return this == ChatStatus.streaming;
  }
}

final class ChatState extends Equatable {
  final ChatStatus status;
  final List<MessageModel> messages;
  final String? activeNode;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.idle,
    this.messages = const [],
    this.activeNode,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<MessageModel>? messages,
    String? activeNode,
    String? errorMessage,
    bool clearActiveNode = false,
    bool clearError = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      activeNode: clearActiveNode ? null : activeNode ?? this.activeNode,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, activeNode, errorMessage];
}
