import 'package:flutter/cupertino.dart';

import 'package:prokurs/constants.dart';
import 'package:prokurs/services/translation_service.dart';

class SignUpForm extends StatefulWidget {
  final void Function(String fullName, String email, String password)? onSignUp;
  final bool isLoading;
  final String? errorMessage;
  const SignUpForm({
    super.key,
    this.onSignUp,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _passwordConfirmationError;
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
        final name = _nameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final passwordConfirmation =
            _passwordConfirmationController.text.trim();

        _nameError = name.isEmpty ? 'Поле обязательно для заполнения' : null;

        _emailError = email.isEmpty
            ? 'Поле обязательно для заполнения'
            : !_isValidEmail(email)
                ? 'Введите валидный email адрес'
                : null;

        _passwordError =
            password.isEmpty ? 'Поле обязательно для заполнения' : null;
        _passwordConfirmationError =
            password != passwordConfirmation ? 'Пароли не совпадают' : null;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Add listeners for live validation
    _nameController.addListener(_validateFields);
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    if (widget.isLoading) return;

    setState(() {
      _submitted = true;
      _validateFields();

      if (_emailError == null &&
          _passwordError == null &&
          _passwordConfirmationError == null &&
          _nameError == null) {
        widget.onSignUp?.call(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Как вас зовут?',
            autofocus: true,
            keyboardType: TextInputType.text,
            cursorColor: DarkTheme.lightSecondary,
            padding: const EdgeInsets.all(16),
            enabled: !widget.isLoading,
            decoration: BoxDecoration(
              border: Border.all(color: DarkTheme.lightSecondary),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          if (_nameError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _nameError!,
                style: const TextStyle(
                  color: CupertinoColors.destructiveRed,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _emailController,
            placeholder: 'Email',
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            cursorColor: DarkTheme.lightSecondary,
            padding: const EdgeInsets.all(16),
            enabled: !widget.isLoading,
            decoration: BoxDecoration(
              border: Border.all(color: DarkTheme.lightSecondary),
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
            obscureText: true,
            cursorColor: DarkTheme.lightSecondary,
            padding: const EdgeInsets.all(16),
            enabled: !widget.isLoading,
            decoration: BoxDecoration(
              border: Border.all(color: DarkTheme.lightSecondary),
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
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _passwordConfirmationController,
            placeholder: 'Подтверждение пароля',
            obscureText: true,
            cursorColor: DarkTheme.lightSecondary,
            padding: const EdgeInsets.all(16),
            enabled: !widget.isLoading,
            decoration: BoxDecoration(
              border: Border.all(color: DarkTheme.lightSecondary),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          if (_passwordConfirmationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _passwordConfirmationError!,
                style: const TextStyle(
                  color: CupertinoColors.destructiveRed,
                  fontSize: 14,
                ),
              ),
            ),
          if (widget.errorMessage != null)
            Container(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                TranslationService.translate(widget.errorMessage!),
                style: const TextStyle(color: CupertinoColors.destructiveRed),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          CupertinoButton(
            color: DarkTheme.generalBlack,
            onPressed: widget.isLoading ? null : _validateAndSubmit,
            child: widget.isLoading
                ? const CupertinoActivityIndicator()
                : const Text('Зарегистрироваться'),
          ),
        ],
      ),
    );
  }
}
