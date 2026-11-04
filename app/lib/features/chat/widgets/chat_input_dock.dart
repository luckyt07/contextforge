import 'package:flutter/material.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';

class ChatInputDock extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isLoading;

  const ChatInputDock({
    required this.onSend,
    this.isLoading = false,
    super.key,
  });

  @override
  State<ChatInputDock> createState() => _ChatInputDockState();
}

class _ChatInputDockState extends State<ChatInputDock> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.spaceMd,
        right: AppSpacing.spaceMd,
        top: AppSpacing.spaceSm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.spaceSm,
      ),
      decoration: BoxDecoration(
        color: colors.canvas,
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: colors.borderDefault),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _handleSend(),
                  style: typo.bodyMd,
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    hintStyle: typo.bodyMd.copyWith(color: colors.textTertiary),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              widget.isLoading
                  ? SizedBox(
                      width: 36,
                      height: 36,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(
                            colors.brandPrimary,
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: _handleSend,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.brandPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
