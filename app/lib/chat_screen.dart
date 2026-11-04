import 'package:ai_assistant_app/bloc/chat_bloc/chat_bloc.dart';
import 'package:ai_assistant_app/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// class ChatScreenWrapper extends StatelessWidget {
//   const ChatScreenWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chat')),
//       body: BlocProvider(
//         create: (_) => ChatBloc(context.read<MessageRepository>()),
//         child: ChatScreen(),
//       ),
//     );
//   }
// }

class ChatScreen extends StatefulWidget {
  final String projectId;
  final String conversationId;

  const ChatScreen({
    required this.projectId,
    required this.conversationId,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final messages = state.messages;
        return Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(child: Text("No messages"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (_, index) =>
                          _MessageBubble(message: messages[index]),
                    ),
            ),

            // Message input
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: state.status.isStreaming()
                          ? null
                          : () {
                              if (messageController.text.trim().isEmpty) {
                                return;
                              }
                              context.read<ChatBloc>().add(
                                ChatSendEvent(
                                  prompt: messageController.text.trim(),
                                  projectId: widget.projectId,
                                  conversationId: widget.conversationId,
                                ),
                              );
                              messageController.clear();
                            },
                      icon: state.status.isStreaming()
                          ? CircularProgressIndicator()
                          : Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final msg = message.message;
    final reasoning = message.reasoning;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            if (reasoning.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.yellow,
                ),
                child: Text(reasoning),
              ),
            Text(msg),
          ],
        ),
      ),
    );
  }
}
