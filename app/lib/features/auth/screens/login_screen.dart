import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../common_widgets/editorial_button.dart';
import '../../../common_widgets/editorial_card.dart';
import '../../../common_widgets/editorial_text_field.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({this.onLoginSuccess, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? true) {
      context.read<AuthBloc>().add(
        AuthLoginEvent(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpScreen(onSignUpSuccess: widget.onLoginSuccess),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            if (widget.onLoginSuccess != null) {
              widget.onLoginSuccess!();
            } else {
              Navigator.of(context).pushReplacementNamed('/projects');
            }
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
          return Stack(
            children: [
              // Ambient warm archival gradient backdrop
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      Positioned(
                        top: -60,
                        right: -50,
                        width: 280,
                        height: 280,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.brandPrimaryContainer.withOpacity(
                              colors.isDark ? 0.20 : 0.45,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.45,
                        left: -70,
                        width: 260,
                        height: 260,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (colors.isDark
                                        ? colors.containerHigh
                                        : const Color(0xFFFFDBD0))
                                    .withOpacity(colors.isDark ? 0.18 : 0.35),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        right: -20,
                        width: 240,
                        height: 240,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.brandPrimaryContainer.withOpacity(
                              colors.isDark ? 0.15 : 0.35,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main vertical content layout
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.spaceLg,
                            vertical: AppSpacing.spaceMd,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  constraints.maxHeight -
                                  (AppSpacing.spaceMd * 2),
                            ),
                            child: IntrinsicHeight(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Top Editorial Header & Monogram
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.spaceMd,
                                        bottom: AppSpacing.spaceLg,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: colors.containerHigh,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppSpacing.radiusXl,
                                                  ),
                                              border: Border.all(
                                                color: colors.borderSubtle,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'S',
                                                style: typo.headline.copyWith(
                                                  color: colors.brandPrimary,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.spaceMd,
                                          ),
                                          Text(
                                            'Sign In',
                                            style: typo.headline.copyWith(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Welcome back to your workspace',
                                            style: typo.bodyMd.copyWith(
                                              color: colors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Central Form Card
                                    EditorialCard(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.spaceLg,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Username field
                                          EditorialTextField(
                                            label: 'Username',
                                            controller: _usernameController,
                                            hintText: 'e.g. alex_dev',
                                            prefixIcon: Icon(
                                              Icons.alternate_email,
                                              size: 18,
                                              color: colors.textTertiary,
                                            ),
                                            textInputAction:
                                                TextInputAction.next,
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.spaceLg,
                                          ),

                                          // Password field
                                          EditorialTextField(
                                            label: 'Password',
                                            controller: _passwordController,
                                            hintText: '••••••••••••',
                                            obscureText: _obscurePassword,
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                              size: 18,
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
                                                  _obscurePassword =
                                                      !_obscurePassword;
                                                });
                                              },
                                            ),
                                            labelTrailing: InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Password recovery link sent if account exists.',
                                                    ),
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                child: Text(
                                                  'Forgot password?',
                                                  style: typo.caption.copyWith(
                                                    color: colors.brandPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            textInputAction:
                                                TextInputAction.done,
                                            onSubmitted: (_) => _handleSignIn(),
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.spaceXl,
                                          ),

                                          // Sign In Button
                                          EditorialButton(
                                            label: 'Sign In',
                                            height: 48,
                                            isFullWidth: true,
                                            isLoading: state.isLoginLoading,
                                            trailingIcon: Icon(
                                              Icons.arrow_forward,
                                              size: 18,
                                              color: colors.brandOnPrimary,
                                            ),
                                            onPressed: _handleSignIn,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Bottom Anchored Link
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.spaceLg,
                                        bottom: AppSpacing.spaceSm,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Don't have an account? ",
                                            style: typo.bodyMd.copyWith(
                                              color: colors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: _navigateToSignUp,
                                            child: Text(
                                              'Sign up',
                                              style: typo.bodyMd.copyWith(
                                                color: colors.brandPrimary,
                                                fontWeight: FontWeight.w700,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    colors.brandPrimary,
                                                fontSize: 14,
                                              ),
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
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
