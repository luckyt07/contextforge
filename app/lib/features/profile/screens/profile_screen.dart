import 'package:flutter/material.dart';
import '../../../common_widgets/editorial_button.dart';
import '../../../common_widgets/editorial_card.dart';
import '../../../common_widgets/editorial_text_field.dart';
import '../../../core/models/response/user.dart';
import '../../../core/repo/auth_repository.dart';
import '../../../bloc/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';

class ProfileScreen extends StatefulWidget {
  final String initialFirstName;
  final String initialLastName;
  final String username;
  final String email;
  final UserInfo? userInfo;

  const ProfileScreen({
    this.initialFirstName = 'Alex',
    this.initialLastName = 'Rivera',
    this.username = 'alex_dev',
    this.email = 'alex.rivera@example.com',
    this.userInfo,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.userInfo?.firstName ?? widget.initialFirstName,
    );
    _lastNameController = TextEditingController(
      text: widget.userInfo?.lastName ?? widget.initialLastName,
    );
    _usernameController = TextEditingController(
      text: widget.userInfo?.username ?? widget.username,
    );
    _emailController = TextEditingController(
      text: widget.userInfo?.email ?? widget.email,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _initials {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final f = first.isNotEmpty ? first[0].toUpperCase() : 'A';
    final l = last.isNotEmpty ? last[0].toUpperCase() : 'R';
    return '$f$l';
  }

  Future<void> _handleSaveProfile() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isNotEmpty) {
      if (_currentPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter your current password.')),
        );
        return;
      }
      if (newPass.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New password must be at least 8 characters long.'),
          ),
        );
        return;
      }
      if (newPass != confirmPass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match.')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final repository = context.read<AuthRepository>();
      final user = await repository.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      if (newPass.isNotEmpty) {
        await repository.changePassword(
          oldPassword: _currentPasswordController.text,
          newPassword: newPass,
          confirmPassword: confirmPass,
        );
      }
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthUpdateProfileEvent(user));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.of(
        context,
      ).pop({'firstName': user.firstName, 'lastName': user.lastName});
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: typo.headline.copyWith(fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.borderSubtle),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
                vertical: AppSpacing.spaceLg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar Header Section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: colors.brandPrimaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colors.borderDefault,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _initials,
                                    style: TextStyle(
                                      color: colors.brandOnPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 28,
                                      fontFamily: 'Merriweather',
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Avatar image picker opened.',
                                        ),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: colors.card,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.borderDefault,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 16,
                                      color: colors.brandPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.spaceSm),
                          Text(
                            '${_firstNameController.text} ${_lastNameController.text}',
                            style: typo.titleLg.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${widget.userInfo?.username ?? widget.username}',
                            style: typo.caption.copyWith(
                              color: colors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                          if (widget.userInfo != null) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              alignment: WrapAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.brandPrimaryContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                  ),
                                  child: Text(
                                    widget.userInfo!.role.toUpperCase(),
                                    style: typo.caption.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: colors.brandOnPrimaryContainer,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.containerLow,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                    border: Border.all(
                                      color: colors.borderSubtle,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: widget.userInfo!.isActive
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.userInfo!.isActive
                                            ? 'Active'
                                            : 'Inactive',
                                        style: typo.caption.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXl),

                    // Section 1: Personal Information (Editable)
                    Text(
                      'Personal Information',
                      style: typo.titleLg.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'These names will appear on your shared workspaces and conversations.',
                      style: typo.caption.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    EditorialCard(
                      padding: const EdgeInsets.all(AppSpacing.spaceMd),
                      child: Column(
                        children: [
                          EditorialTextField(
                            label: 'First Name',
                            isRequired: true,
                            controller: _firstNameController,
                            hintText: 'e.g. Alex',
                            prefixIcon: Icon(
                              Icons.badge_outlined,
                              size: 19,
                              color: colors.textTertiary,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          EditorialTextField(
                            label: 'Last Name',
                            isRequired: true,
                            controller: _lastNameController,
                            hintText: 'e.g. Rivera',
                            prefixIcon: Icon(
                              Icons.draw_outlined,
                              size: 19,
                              color: colors.textTertiary,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXl),

                    // Section 2: Account Identifiers (Fixed / Read-only)
                    Row(
                      children: [
                        Text(
                          'Account Identifiers',
                          style: typo.titleLg.copyWith(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.containerLow,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(color: colors.borderSubtle),
                          ),
                          child: Text(
                            'FIXED',
                            style: typo.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your username and email address are locked to your workspace identity.',
                      style: typo.caption.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    EditorialCard(
                      padding: const EdgeInsets.all(AppSpacing.spaceMd),
                      child: Column(
                        children: [
                          EditorialTextField(
                            label: 'Username',
                            controller: _usernameController,
                            enabled: false,
                            prefixIcon: Icon(
                              Icons.alternate_email,
                              size: 19,
                              color: colors.textTertiary,
                            ),
                            suffixIcon: Tooltip(
                              message: 'Username cannot be modified',
                              child: Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: colors.textTertiary,
                              ),
                            ),
                            helperText: 'Username cannot be changed',
                          ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          EditorialTextField(
                            label: 'Email',
                            controller: _emailController,
                            enabled: false,
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              size: 19,
                              color: colors.textTertiary,
                            ),
                            suffixIcon: Tooltip(
                              message: 'Email is permanently linked',
                              child: Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: colors.textTertiary,
                              ),
                            ),
                            helperText:
                                'Email is permanently linked to your account',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXl),

                    // Section 3: Security & Password (Editable)
                    Text(
                      'Security & Password',
                      style: typo.titleLg.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Leave blank if you do not want to change your password.',
                      style: typo.caption.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    EditorialCard(
                      padding: const EdgeInsets.all(AppSpacing.spaceMd),
                      child: Column(
                        children: [
                          EditorialTextField(
                            label: 'Current Password',
                            controller: _currentPasswordController,
                            hintText: 'Enter current password',
                            obscureText: _obscureCurrentPassword,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              size: 19,
                              color: colors.textTertiary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 19,
                                color: colors.textTertiary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          EditorialTextField(
                            label: 'New Password',
                            controller: _newPasswordController,
                            hintText: 'At least 8 characters',
                            obscureText: _obscureNewPassword,
                            prefixIcon: Icon(
                              Icons.lock_reset_outlined,
                              size: 19,
                              color: colors.textTertiary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 19,
                                color: colors.textTertiary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          EditorialTextField(
                            label: 'Confirm New Password',
                            controller: _confirmPasswordController,
                            hintText: 'Re-enter new password',
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              size: 19,
                              color: colors.textTertiary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 19,
                                color: colors.textTertiary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2xl),

                    // Actions
                    EditorialButton(
                      label: 'Save Changes',
                      height: 48,
                      isFullWidth: true,
                      isLoading: _isLoading,
                      trailingIcon: Icon(
                        Icons.check,
                        size: 18,
                        color: colors.brandOnPrimary,
                      ),
                      onPressed: _handleSaveProfile,
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    EditorialButton(
                      label: 'Cancel',
                      height: 48,
                      isFullWidth: true,
                      variant: EditorialButtonVariant.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
