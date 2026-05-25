import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/widgets/app_button.dart';
import 'package:calcount/common/widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    // Navigate straight to onboarding welcome since they are registering
    context.go(AppRoutes.onboardingWelcome);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.width(28),
          vertical: AppDimensions.height(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: AppDimensions.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.userPlus,
                  color: colors.primary,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: AppDimensions.md),
            Text(
              'Create Account',
              style: AppTypography.headingXl(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.xxs),
            Text(
              'Start your organic nutrition journey today',
              style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.xl),

            // Name
            Text(
              'Full Name',
              style: AppTypography.headingSm(color: colors.onSurface),
            ),
            SizedBox(height: AppDimensions.xs),
            AppTextField(
              controller: _nameController,
              hint: 'Alex Johnson',
              prefix: const Icon(LucideIcons.user),
            ),
            SizedBox(height: AppDimensions.lg),

            // Email
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

            // Password
            Text(
              'Password',
              style: AppTypography.headingSm(color: colors.onSurface),
            ),
            SizedBox(height: AppDimensions.xs),
            AppTextField.password(
              controller: _passwordController,
              hint: 'Minimum 8 characters',
              prefix: const Icon(LucideIcons.lock),
            ),
            SizedBox(height: AppDimensions.xl),

            // Action
            AppButton.primary(label: 'Create Account', onPressed: _onSignUp),
            SizedBox(height: AppDimensions.lg),

            // Terms Note
            Text(
              'By signing up, you agree to our Terms of Service & Privacy Policy.',
              style: AppTypography.bodySm(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.xl),

            // Bottom redirects
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text(
                    'Sign In',
                    style: AppTypography.bodyMd(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }
}
