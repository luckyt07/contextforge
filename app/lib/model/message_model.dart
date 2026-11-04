import 'package:equatable/equatable.dart';

final class MessageModel extends Equatable {
  final String message;
  final String reasoning;
  final bool isUser;

  const MessageModel({
    required this.message,
    this.isUser = false,
    this.reasoning = "",
  });

  MessageModel copyWith({
    required String message,
    required String reasoning,
    bool? isUser,
  }) {
    return MessageModel(
      message: this.message + message,
      isUser: isUser ?? this.isUser,
      reasoning: this.reasoning + reasoning,
    );
  }

  @override
  List<Object?> get props => [message, isUser, reasoning];
}
