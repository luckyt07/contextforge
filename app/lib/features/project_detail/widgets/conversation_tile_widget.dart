import 'package:flutter/material.dart';
import '../../../common_widgets/editorial_card.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';
import '../models/conversation_item.dart';

class ConversationTileWidget extends StatelessWidget {
  final ConversationItem conversation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ConversationTileWidget({
    required this.conversation,
    this.onTap,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    return EditorialCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  style: typo.titleMd.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  conversation.timestamp,
                  style: typo.caption.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, size: 20, color: colors.textTertiary),
            onSelected: (value) {
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete conversation'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
