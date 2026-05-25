import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/common/widgets/app_button.dart';
import 'package:calcount/common/widgets/app_text_field.dart';
import 'package:calcount/common/widgets/auth_header_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    // Simply bypass credentials to maintain immediate, highly interactive experience
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top decorative brand gradient shape
            const AuthHeaderBackground(),
            Padding(
              padding: AppDimensions.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome Back',
                    style: AppTypography.headingXl(color: colors.onSurface),
                  ),
                  SizedBox(height: AppDimensions.xxs),
                  Text(
                    'Sign in to continue tracking your meals',
                    style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
                  ),
                  SizedBox(height: AppDimensions.xl),
                  Text(
                    'Email Address',
                    style: AppTypography.headingSm(color: colors.onSurface),
                  ),
                  SizedBox(height: AppDimensions.xs),
                  AppTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hint: 'name@example.com',
                    prefix: const Icon(LucideIcons.mail),
                  ),
                  SizedBox(height: AppDimensions.lg),
                  Text(
                    'Password',
                    style: AppTypography.headingSm(color: colors.onSurface),
                  ),
                  SizedBox(height: AppDimensions.xs),
                  AppTextField.password(
                    controller: _passwordController,
                    hint: '********',
                    prefix: const Icon(LucideIcons.lock),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton.text(
                      label: 'Forgot Password?',
                      onPressed: () {},
                      isExpanded: false,
                    ),
                  ),
                  SizedBox(height: AppDimensions.sm),
                  AppButton.primary(label: 'Sign In', onPressed: _onSignIn),
                  SizedBox(height: AppDimensions.lg),
                  Row(
                    children: [
                      Expanded(child: Divider(color: colors.outline)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.width(16),
                        ),
                        child: Text(
                          'or continue with',
                          style: AppTypography.bodySm(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colors.outline)),
                    ],
                  ),
                  SizedBox(height: AppDimensions.lg),
                  AppButton.outlined(
                    label: 'Continue with Google',
                    icon: const Icon(LucideIcons.chrome, size: 20),
                    onPressed: _onSignIn,
                  ),
                  SizedBox(height: AppDimensions.sm),
                  AppButton.primary(
                    label: 'Continue with Apple',
                    icon: const Icon(LucideIcons.apple, size: 20),
                    onPressed: _onSignIn,
                  ),
                  SizedBox(height: AppDimensions.xl),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.bodyMd(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: AppDimensions.xxs),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.signup),
                        child: Text(
                          'Sign Up',
                          style: AppTypography.bodyMd(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
