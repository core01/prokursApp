import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';

class SignInForm extends StatefulWidget {
  final VoidCallback? onSignUp;
  final void Function(String email, String password)? onSignIn;
  final String? signInError;
  const SignInForm({
    super.key,
    this.onSignUp,
    this.onSignIn,
    this.signInError,
  });

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _emailController = TextEditingController();
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

        _passwordError =
            password.isEmpty ? 'Поле обязательно для заполнения' : null;
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CupertinoTextField(
              controller: _emailController,
              placeholder: 'Email',
              // placeholderStyle: TextStyle(color: AppColors.lightSecondary),
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              cursorColor: AppColors.darkSecondary,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkSecondary),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            if (_emailError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _emailError!,
                  style: const TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: 'Пароль',
              // placeholderStyle: TextStyle(color: AppColors.lightSecondary),
              obscureText: true,
              cursorColor: AppColors.darkSecondary,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkSecondary),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            if (_passwordError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _passwordError!,
                  style: const TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontSize: 14,
                  ),
                ),
              ),
            if (widget.signInError != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  widget.signInError!,
                  style: const TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: _validateAndSubmit,
              child: const Text('Войти'),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: widget.onSignUp,
              child: const Center(
                child: Text(
                  'Еще нет аккаунта? Зарегистрируйтесь',
                  style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
