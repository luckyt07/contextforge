import 'package:ai_assistant_app/core/models/response/project_model.dart';
import 'package:ai_assistant_app/core/repo/project_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common_widgets/editorial_button.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';
import '../../chat/screens/editorial_chat_screen.dart';
import '../models/conversation_item.dart';
import '../widgets/conversation_tile_widget.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({required this.project, super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  List<ConversationItem> _conversations = const [];
  bool _isLoadingConversations = true;
  String? _conversationError;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoadingConversations = true;
      _conversationError = null;
    });
    try {
      final conversations = await context
          .read<ProjectRepository>()
          .getProjectConversations(widget.project.id);
      if (!mounted) return;
      setState(() {
        _conversations = conversations
            .map(
              (conversation) => ConversationItem(
                id: conversation.conversationId,
                title: conversation.conversationTitle,
                snippet: '',
                timestamp: _relativeTime(conversation.updatedAt),
              ),
            )
            .toList();
        _isLoadingConversations = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingConversations = false;
        _conversationError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _deleteConversation(ConversationItem conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text('“${conversation.title}” will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<ProjectRepository>().deleteProjectConversation(
        conversation.id,
      );
      await _loadConversations();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Conversation deleted.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  void _navigateToChat([ConversationItem? conversation]) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ChatScreenWrapper(
              projectTitle: widget.project.projectName,
              conversationTitle: conversation?.title ?? 'New Conversation',
              projectId: widget.project.id,
              conversationId: conversation?.id,
            ),
          ),
        )
        .then((_) => _loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.project.projectName,
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
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          children: [
            Text(
              widget.project.projectName,
              style: typo.headline.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              widget.project.instruction,
              style: typo.bodyMd.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // + New Chat Button
            EditorialButton(
              label: 'New Chat',
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              isFullWidth: true,
              onPressed: () => _navigateToChat(),
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            // Section Header: Conversations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conversations',
                  style: typo.titleLg.copyWith(fontSize: 18),
                ),
                Text(
                  '${_conversations.length} chats',
                  style: typo.labelMd.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),

            // Conversations List
            if (_isLoadingConversations)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.spaceLg),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_conversationError != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spaceMd,
                ),
                child: Text(
                  _conversationError!,
                  style: typo.bodyMd.copyWith(color: colors.error),
                ),
              )
            else if (_conversations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spaceMd,
                ),
                child: Text(
                  'No conversations yet. Start a new chat.',
                  style: typo.bodyMd.copyWith(color: colors.textSecondary),
                ),
              )
            else
              ..._conversations.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                  child: ConversationTileWidget(
                    conversation: c,
                    onTap: () => _navigateToChat(c),
                    onDelete: () => _deleteConversation(c),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date.toLocal());
    if (difference.inMinutes < 1) return 'Active now';
    if (difference.inHours < 1) return 'Active ${difference.inMinutes}m ago';
    if (difference.inDays < 1) return 'Active ${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
