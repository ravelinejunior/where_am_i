import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:where_am_i/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../../core/router/route_names.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../app/app.dart';

class LoginScreen extends StatelessWidget {
  final String? redirectTo;
  const LoginScreen({super.key, this.redirectTo});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: _LoginView(redirectTo: redirectTo),
    );
  }
}

class _LoginView extends StatefulWidget {
  final String? redirectTo;
  const _LoginView({this.redirectTo});

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAuthSuccess(BuildContext context) {
    if (widget.redirectTo != null) {
      context.go(widget.redirectTo!);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteNames.missingListName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.isAuthenticated) _handleAuthSuccess(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    if (Navigator.of(context).canPop())
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ),

                    const SizedBox(height: 40),

                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_search_rounded,
                          color: AppColors.textOnRed, size: 24),
                    ),
                    const SizedBox(height: 20),
                    Text(l.loginTitle, style: AppTextTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text(
                      l.loginSubtitle,
                      style: AppTextTheme.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 36),

                    // Email confirmation banner
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (p, c) => p.status != c.status,
                      builder: (context, state) {
                        if (!state.needsEmailConfirmation) {
                          return const SizedBox.shrink();
                        }
                        return _SuccessBanner(
                            message: l.loginEmailConfirmation);
                      },
                    ),

                    // Error banner
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (p, c) => p.errorMessage != c.errorMessage,
                      builder: (context, state) {
                        if (state.errorMessage == null) {
                          return const SizedBox.shrink();
                        }
                        return _ErrorBanner(message: state.errorMessage!);
                      },
                    ),

                    // Success banner
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (p, c) => p.successMessage != c.successMessage,
                      builder: (context, state) {
                        if (state.successMessage == null) {
                          return const SizedBox.shrink();
                        }
                        return _SuccessBanner(message: state.successMessage!);
                      },
                    ),

                    _GoogleButton(),
                    const SizedBox(height: 20),

                    Row(children: [
                      const Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('ou',
                            style: AppTextTheme.bodySmall
                                .copyWith(color: AppColors.textMuted)),
                      ),
                      const Expanded(child: Divider(color: AppColors.divider)),
                    ]),
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppColors.border, width: 0.5),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerHeight: 0,
                        labelStyle: AppTextTheme.labelLarge,
                        unselectedLabelStyle: AppTextTheme.labelLarge
                            .copyWith(color: AppColors.textMuted),
                        tabs: [
                          Tab(text: l.loginSignIn),
                          Tab(text: l.loginCreateAccount),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 360,
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          _SignInForm(),
                          _SignUpForm(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.isLoading != c.isLoading,
      builder: (context, state) => OutlinedButton(
        onPressed: state.isLoading
            ? null
            : () =>
                context.read<AuthBloc>().add(const AuthGoogleSignInRequested()),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.border, width: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text('G',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4285F4),
                    )),
              ),
            ),
            const SizedBox(width: 12),
            Text(l.loginGoogle,
                style: AppTextTheme.labelLarge
                    .copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();
  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EmailField(controller: _emailCtrl),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _passwordCtrl,
            obscure: _obscure,
            onToggle: () => setState(() => _obscure = !_obscure),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _forgotPassword(context),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
              child: Text(l.loginForgotPassword,
                  style: AppTextTheme.labelMedium
                      .copyWith(color: AppColors.primaryLight)),
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (p, c) => p.isLoading != c.isLoading,
            builder: (context, state) => ElevatedButton(
              onPressed: state.isLoading ? null : () => _submit(context),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.textOnRed, strokeWidth: 2))
                  : Text(l.loginSignIn),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthEmailSignInRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  void _forgotPassword(BuildContext context) {
    final l = context.l10n;
    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.loginEmailLabel)));
      return;
    }
    context
        .read<AuthBloc>()
        .add(AuthPasswordResetRequested(_emailCtrl.text.trim()));
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();
  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _InputField(
            controller: _nameCtrl,
            label: l.loginNameLabel,
            hint: l.loginNameHint,
            keyboardType: TextInputType.name,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
          ),
          const SizedBox(height: 12),
          _EmailField(controller: _emailCtrl),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _passwordCtrl,
            obscure: _obscure,
            onToggle: () => setState(() => _obscure = !_obscure),
          ),
          const SizedBox(height: 20),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (p, c) => p.isLoading != c.isLoading,
            builder: (context, state) => ElevatedButton(
              onPressed: state.isLoading ? null : () => _submit(context),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.textOnRed, strokeWidth: 2))
                  : Text(l.loginCreateAccount),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthEmailSignUpRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          displayName: _nameCtrl.text.trim(),
        ));
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscure;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.validator,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: AppTextTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
      ),
      validator: validator,
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _InputField(
      controller: controller,
      label: l.loginEmailLabel,
      hint: l.loginEmailHint,
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email obrigatório';
        if (!v.contains('@')) return 'Email inválido';
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _InputField(
      controller: controller,
      label: l.loginPasswordLabel,
      hint: l.loginPasswordHint,
      obscure: obscure,
      suffix: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 18,
          color: AppColors.textMuted,
        ),
        onPressed: onToggle,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Senha obrigatória';
        if (v.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            size: 16, color: AppColors.danger),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
              style: AppTextTheme.bodySmall.copyWith(color: AppColors.danger)),
        ),
      ]),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String message;
  const _SuccessBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_outline_rounded,
            size: 16, color: AppColors.success),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
              style: AppTextTheme.bodySmall
                  .copyWith(color: const Color(0xFF4CAF50))),
        ),
      ]),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
