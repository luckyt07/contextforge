import 'package:flutter/material.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';

class ThemeSegmentedPicker extends StatelessWidget {
  final AppThemeMode selectedMode;
  final ValueChanged<AppThemeMode> onModeChanged;

  const ThemeSegmentedPicker({
    required this.selectedMode,
    required this.onModeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.containerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          _buildItem(
            context,
            mode: AppThemeMode.light,
            label: 'Light',
            icon: Icons.light_mode_outlined,
          ),
          _buildItem(
            context,
            mode: AppThemeMode.dark,
            label: 'Dark',
            icon: Icons.dark_mode_outlined,
          ),
          _buildItem(
            context,
            mode: AppThemeMode.system,
            label: 'System',
            icon: Icons.desktop_windows_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required AppThemeMode mode,
    required String label,
    required IconData icon,
  }) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;
    final isSelected = selectedMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () => onModeChanged(mode),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: isSelected ? Border.all(color: colors.borderDefault) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? colors.textPrimary : colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: typo.labelMd.copyWith(
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
