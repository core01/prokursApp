import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';

class SignInForm extends StatefulWidget {
  final VoidCallback? onSignUp;
  final void Function(String email, String password)? onSignIn;
  final String? signInError;

  /// Prefills the email, e.g. from the session that just expired.
  final String? initialEmail;

  /// Shown above the fields, with their width: why the user has to sign in.
  final Widget? notice;

  const SignInForm({
    super.key,
    this.onSignUp,
    this.onSignIn,
    this.signInError,
    this.initialEmail,
    this.notice,
  });

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  late final TextEditingController _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _submitted = false;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _validateFields() {
    setState(() {
      if (_submitted) {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        _emailError = email.isEmpty
            ? 'Поле обязательно для заполнения'
            : !_isValidEmail(email)
            ? 'Введите валидный email адрес'
            : null;

        _passwordError = password.isEmpty
            ? 'Поле обязательно для заполнения'
            : null;
      }
    });
  }

  void _validateAndSubmit() {
    setState(() {
      _submitted = true;
      _validateFields();

      if (_emailError == null && _passwordError == null) {
        widget.onSignIn?.call(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Add listeners for live validation
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.notice != null) ...[
          widget.notice!,
          const SizedBox(height: AppSpacing.md),
        ],
        CupertinoTextField(
          controller: _emailController,
          placeholder: 'Email',
          placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
          autofocus: widget.initialEmail == null,
          keyboardType: TextInputType.emailAddress,
          clearButtonMode: OverlayVisibilityMode.editing,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.inputBorder,
              width: AppStroke.hairline,
            ),
            borderRadius: AppRadius.control,
          ),
        ),
        if (_emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _emailError!,
              style: AppTypography.footnote.copyWith(
                color: AppColors.error.resolveFrom(context),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        CupertinoTextField(
          controller: _passwordController,
          placeholder: 'Пароль',
          placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
          autofocus: widget.initialEmail != null,
          obscureText: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.inputBorder,
              width: AppStroke.hairline,
            ),
            borderRadius: AppRadius.control,
          ),
        ),
        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _passwordError!,
              style: AppTypography.footnote.copyWith(
                color: AppColors.error.resolveFrom(context),
              ),
            ),
          ),
        if (widget.signInError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Text(
              widget.signInError!,
              style: AppTypography.footnote.copyWith(
                color: AppColors.error.resolveFrom(context),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        CupertinoButton.filled(
          borderRadius: AppRadius.card,
          onPressed: _validateAndSubmit,
          child: const Text('Войти'),
        ),
        const SizedBox(height: AppSpacing.md),
        CupertinoButton(
          onPressed: widget.onSignUp,
          child: Text(
            'Еще нет аккаунта? Зарегистрируйтесь',
            textAlign: TextAlign.center,
            style: AppTypography.callout.copyWith(
              color: AppColors.link.resolveFrom(context),
            ),
          ),
        ),
      ],
    );
  }
}
