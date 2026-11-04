import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/editorial_theme_scope.dart';

enum EditorialButtonVariant { primary, secondary, outline }

class EditorialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? trailingIcon;
  final String label;
  final EditorialButtonVariant variant;
  final bool isFullWidth;
  final double height;
  final bool isLoading;

  const EditorialButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = EditorialButtonVariant.primary,
    this.isFullWidth = false,
    this.height = 46.0,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;

    Color bg;
    Color fg;
    BorderSide border;

    switch (variant) {
      case EditorialButtonVariant.primary:
        bg = colors.brandPrimary;
        fg = colors.brandOnPrimary;
        border = BorderSide.none;
        break;
      case EditorialButtonVariant.secondary:
        bg = colors.containerLow;
        fg = colors.textPrimary;
        border = BorderSide.none;
        break;
      case EditorialButtonVariant.outline:
        bg = Colors.transparent;
        fg = colors.textPrimary;
        border = BorderSide(color: colors.borderDefault);
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.spaceXs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.spaceXs),
            trailingIcon!,
          ],
        ],
      );
    }

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: border,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
