import 'package:flutter/material.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';

class InstructionCardWidget extends StatelessWidget {
  final String instructions;

  const InstructionCardWidget({required this.instructions, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm + 2),
      decoration: BoxDecoration(
        color: colors.surfaceSubdued,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: colors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INSTRUCTIONS',
                style: typo.labelMd.copyWith(
                  letterSpacing: 0.8,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                ),
              ),
              Icon(Icons.tune, size: 16, color: colors.textTertiary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '“$instructions”',
            style: typo.bodyMd.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
