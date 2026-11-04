import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/editorial_theme_scope.dart';

class EditorialCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;

  const EditorialCard({
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final cardBg = backgroundColor ?? colors.card;
    final border = borderColor ?? colors.borderDefault;
    final radius = borderRadius ?? AppSpacing.radiusXl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.spaceMd),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
