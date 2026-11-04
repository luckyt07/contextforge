import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../common_widgets/editorial_button.dart';
import '../../../common_widgets/editorial_text_field.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onSignUpSuccess;

  const SignUpScreen({this.onSignUpSuccess, super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() {
    if (_formKey.currentState?.validate() ?? true) {
      context.read<AuthBloc>().add(
        AuthRegisterEvent(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        ),
      );
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
        title: Text('Sign Up', style: typo.headline.copyWith(fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.borderSubtle),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.registered) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.successMessage ?? 'Account created! Please sign in.',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            // Navigate back to login page to re-login as specified
            Navigator.of(context).pop();
          } else if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceLg,
                    vertical: AppSpacing.spaceLg,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Introduction Title
                        Text(
                          'Create Account',
                          style: typo.headline.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Set up your personal workspace and start orchestrating your thought threads.',
                          style: typo.bodyMd.copyWith(
                            color: colors.textSecondary,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceXl),

                        // First Name
                        EditorialTextField(
                          label: 'First Name',
                          isRequired: true,
                          controller: _firstNameController,
                          hintText: 'e.g. Alex',
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                            size: 20,
                            color: colors.textTertiary,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.spaceMd),

                        // Last Name
                        EditorialTextField(
                          label: 'Last Name',
                          isRequired: true,
                          controller: _lastNameController,
                          hintText: 'e.g. Rivera',
                          prefixIcon: Icon(
                            Icons.draw_outlined,
                            size: 20,
                            color: colors.textTertiary,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.spaceMd),

                        // Username
                        EditorialTextField(
                          label: 'Username',
                          isRequired: true,
                          controller: _usernameController,
                          hintText: 'e.g. alex_dev',
                          prefixIcon: Icon(
                            Icons.alternate_email,
                            size: 20,
                            color: colors.textTertiary,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.spaceMd),

                        // Email
                        EditorialTextField(
                          label: 'Email',
                          isRequired: true,
                          controller: _emailController,
                          hintText: 'alex.rivera@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline,
                            size: 20,
                            color: colors.textTertiary,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.spaceMd),

                        // Password
                        EditorialTextField(
                          label: 'Password',
                          isRequired: true,
                          controller: _passwordController,
                          hintText: 'At least 8 characters',
                          obscureText: _obscurePassword,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: colors.textTertiary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                              color: colors.textTertiary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleCreateAccount(),
                        ),
                        const SizedBox(height: AppSpacing.space2xl),

                        // Create Account CTA Button
                        EditorialButton(
                          label: 'Create Account',
                          height: 48,
                          isFullWidth: true,
                          isLoading: state.isRegisterLoading,
                          trailingIcon: Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: colors.brandOnPrimary,
                          ),
                          onPressed: _handleCreateAccount,
                        ),
                        const SizedBox(height: AppSpacing.spaceLg),

                        // Already have an account? Sign in
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: typo.bodyMd.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Sign in',
                                  style: typo.bodyMd.copyWith(
                                    color: colors.brandPrimary,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: colors.brandPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceMd),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
