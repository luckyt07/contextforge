import 'package:ai_assistant_app/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant_app/theme/app_spacing.dart';
import 'package:ai_assistant_app/theme/editorial_theme_scope.dart';

class ChatMessageItem {
  final bool isUser;
  final String text;
  final String timestamp;
  final String? codeSnippet;
  final String? codeTitle;

  const ChatMessageItem({
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.codeSnippet,
    this.codeTitle,
  });
}

class ChatMessageBubble extends StatelessWidget {
  final MessageModel message;

  const ChatMessageBubble({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(left: 48, bottom: AppSpacing.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusXl),
                    bottomLeft: Radius.circular(AppSpacing.radiusXl),
                    bottomRight: Radius.circular(AppSpacing.radiusXl),
                  ),
                  border: Border.all(color: colors.borderDefault),
                ),
                child: Text(
                  message.message,
                  style: typo.bodyMd.copyWith(height: 1.5),
                ),
              ),
              const SizedBox(height: 4),
              // Text(
              //   message.timestamp,
              //   style: typo.caption.copyWith(
              //     color: colors.textTertiary,
              //   ),
              // ),
            ],
          ),
        ),
      );
    }

    // AI Assistant response (Warm editorial layout rendered on substrate)
    return Container(
      margin: const EdgeInsets.only(right: 16, bottom: AppSpacing.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.reasoning.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.green,
              ),
              child: Text(message.reasoning),
            ),
          Text(
            message.message,
            style: typo.bodyMd.copyWith(fontSize: 14.5, height: 1.6),
          ),
          // if (message.codeSnippet != null) ...[
          //   const SizedBox(height: AppSpacing.spaceSm),
          //   CodeSnippetCard(
          //     title: message.codeTitle,
          //     code: message.codeSnippet!,
          //   ),
          // ],
          // const SizedBox(height: 6),
          // Text(
          //   message.timestamp,
          //   style: typo.caption.copyWith(
          //     color: colors.textTertiary,
          //   ),
          // ),
        ],
      ),
    );
  }
}
