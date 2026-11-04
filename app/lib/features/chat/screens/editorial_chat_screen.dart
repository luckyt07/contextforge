import 'package:ai_assistant_app/bloc/chat_bloc/chat_bloc.dart';
import 'package:ai_assistant_app/core/repo/message_repository.dart';
import 'package:ai_assistant_app/core/repo/project_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';
import '../widgets/chat_input_dock.dart';
import '../widgets/chat_message_bubble.dart';

class ChatScreenWrapper extends StatelessWidget {
  final String projectTitle;
  final String conversationTitle;
  final String projectId;
  final String? conversationId;

  const ChatScreenWrapper({
    required this.projectId,
    this.conversationId,
    this.projectTitle = 'Flutter Architecture',
    this.conversationTitle = 'Responsive layouts for iPad and Web viewport',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(context.read<MessageRepository>()),
      child: EditorialChatScreen(
        projectId: projectId,
        conversationId: conversationId,
        conversationTitle: conversationTitle,
        projectTitle: projectTitle,
      ),
    );
  }
}

class EditorialChatScreen extends StatefulWidget {
  final String projectTitle;
  final String conversationTitle;
  final String projectId;
  final String? conversationId;

  const EditorialChatScreen({
    required this.projectId,
    this.conversationId,
    this.projectTitle = 'Flutter Architecture',
    this.conversationTitle = 'Responsive layouts for iPad and Web viewport',
    super.key,
  });

  @override
  State<EditorialChatScreen> createState() => _EditorialChatScreenState();
}

class _EditorialChatScreenState extends State<EditorialChatScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    if (_conversationId != null) {
      context.read<ChatBloc>().add(ChatHistoryEvent(_conversationId!));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    context.read<ChatBloc>().add(
      ChatSendEvent(
        prompt: text,
        projectId: widget.projectId,
        conversationId: _conversationId,
      ),
    );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        _scrollToBottom();
        if (state.status == ChatStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.status == ChatStatus.idle && _conversationId == null) {
          _adoptServerConversation();
        }
      },
      builder: (context, state) {
        final messages = state.messages;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              widget.projectTitle,
              style: typo.headline.copyWith(fontSize: 18),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              const SizedBox(width: AppSpacing.spaceXs),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: colors.borderSubtle),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Reading lane - max width ergonomically clamped for tablet/desktop readiness
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 768),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spaceMd,
                          vertical: AppSpacing.spaceMd,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return ChatMessageBubble(message: messages[index]);
                        },
                      ),
                    ),
                  ),
                ),

                if (state.status.isStreaming() && state.activeNode != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceMd,
                      vertical: AppSpacing.spaceXs,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: AppSpacing.spaceSm),
                        Text(
                          'Running ${_nodeLabel(state.activeNode!)}',
                          style: typo.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bottom input dock
                ChatInputDock(
                  isLoading: state.status.isStreaming(),
                  onSend: _sendMessage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _nodeLabel(String node) {
    switch (node) {
      case 'query_rewriting':
        return 'query rewriting';
      case 'llm_reasoning':
        return 'LLM reasoning';
      case 'llm_call':
        return 'LLM response';
      default:
        return node;
    }
  }

  Future<void> _adoptServerConversation() async {
    // The server creates a conversation in a background task after the first
    // prompt. Once it is available, reuse its ID for the next LangGraph turn.
    final projectRepository = context.read<ProjectRepository>();
    final projectId = widget.projectId;
    for (
      var attempt = 0;
      attempt < 5 && mounted && _conversationId == null;
      attempt++
    ) {
      final conversations = await projectRepository.getProjectConversations(
        projectId,
      );
      if (conversations.isNotEmpty) {
        conversations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (mounted) {
          setState(() => _conversationId = conversations.first.conversationId);
        }
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }
}
