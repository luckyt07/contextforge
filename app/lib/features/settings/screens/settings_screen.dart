import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../common_widgets/editorial_card.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/theme_segmented_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _firstName = 'Alex';
  String _lastName = 'Rivera';
  final String _defaultUsername = 'alex_dev';
  final String _defaultEmail = 'alex.rivera@example.com';

  String _initials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : 'R';
    return '$f$l';
  }

  void _openProfile() async {
    final authState = context.read<AuthBloc>().state;
    final user = authState.currentUser;
    final currentUsername = user?.username ?? _defaultUsername;
    final currentEmail = user?.email ?? _defaultEmail;
    _firstName = user?.firstName ?? _firstName;
    _lastName = user?.lastName ?? _lastName;

    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          initialFirstName: _firstName,
          initialLastName: _lastName,
          username: currentUsername,
          email: currentEmail,
          userInfo: user,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _firstName = result['firstName'] ?? _firstName;
        _lastName = result['lastName'] ?? _lastName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;
    final themeController = context.editorialTheme;

    final authState = context.watch<AuthBloc>().state;
    final user = authState.currentUser;
    final displayedUsername = user?.username ?? _defaultUsername;
    final displayedEmail = user?.email ?? _defaultEmail;
    final firstname = user?.firstName ?? _firstName;
    final lastname = user?.lastName ?? _lastName;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settings', style: typo.headline.copyWith(fontSize: 18)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: colors.containerLow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Center(
              child: Text(
                'v1.0.4',
                style: typo.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.borderSubtle),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              children: [
                // SECTION: Account
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Account', style: typo.titleLg.copyWith(fontSize: 18)),
                    TextButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthLogoutEvent());
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      },
                      icon: Icon(Icons.logout, size: 16, color: colors.error),
                      label: Text(
                        'Log out',
                        style: TextStyle(
                          color: colors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                EditorialCard(
                  onTap: _openProfile,
                  padding: const EdgeInsets.all(AppSpacing.spaceMd),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.brandPrimaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _initials(firstname, lastname),
                            style: TextStyle(
                              color: colors.brandOnPrimaryContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$firstname $lastname',
                                  style: typo.titleMd,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '@$displayedUsername',
                                  style: typo.caption.copyWith(
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayedEmail,
                              style: typo.bodyMd.copyWith(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: colors.textSecondary,
                        ),
                        onPressed: _openProfile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXl),

                // SECTION: Appearance & Theme
                Text(
                  'Appearance & Theme',
                  style: typo.titleLg.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                EditorialCard(
                  padding: const EdgeInsets.all(AppSpacing.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interface Theme',
                        style: typo.titleMd.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),
                      ThemeSegmentedPicker(
                        selectedMode: themeController.mode,
                        onModeChanged: (mode) {
                          themeController.setThemeMode(
                            mode,
                            MediaQuery.platformBrightnessOf(context),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXl),

                EditorialCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.spaceMd),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Version',
                                  style: typo.titleMd.copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'v1.0.4 (Build 42)',
                                  style: typo.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('App is up to date.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.containerLow,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  'Check for updates',
                                  style: typo.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
