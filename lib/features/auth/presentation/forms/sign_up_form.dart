import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/services/translation_service.dart';
import 'package:prokurs/core/utils/organization_rules.dart';

/// What the form hands over once it is valid. [bin] is the clean number (no spaces).
class SignUpData {
  const SignUpData({
    required this.fullName,
    required this.email,
    required this.password,
    required this.organizationName,
    required this.bin,
  });

  final String fullName;
  final String email;
  final String password;
  final String organizationName;
  final String bin;
}

class SignUpForm extends StatefulWidget {
  final void Function(SignUpData data)? onSignUp;
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
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _binController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _organizationError;
  String? _binError;
  String? _passwordError;
  String? _passwordConfirmationError;
  bool _submitted = false;

  Widget _fieldError(String text) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          text,
          style: AppTypography.footnote.copyWith(
            color: AppColors.error.resolveFrom(context),
          ),
        ),
      );

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
        final organization = _organizationController.text.trim();
        final bin = normalizeBin(_binController.text);
        final password = _passwordController.text.trim();
        final passwordConfirmation = _passwordConfirmationController.text
            .trim();

        _nameError = name.isEmpty ? 'Поле обязательно для заполнения' : null;

        _emailError = email.isEmpty
            ? 'Поле обязательно для заполнения'
            : !_isValidEmail(email)
            ? 'Введите валидный email адрес'
            : null;

        _organizationError =
            organization.isEmpty ? 'Поле обязательно для заполнения' : null;

        _binError = bin.isEmpty
            ? 'Поле обязательно для заполнения'
            : !isValidBin(bin)
            ? 'Неверный БИН: проверьте все 12 цифр'
            : null;

        _passwordError = password.isEmpty
            ? 'Поле обязательно для заполнения'
            : null;
        _passwordConfirmationError = password != passwordConfirmation
            ? 'Пароли не совпадают'
            : null;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Add listeners for live validation
    _nameController.addListener(_validateFields);
    _emailController.addListener(_validateFields);
    _organizationController.addListener(_validateFields);
    _binController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _organizationController.dispose();
    _binController.dispose();
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
          _organizationError == null &&
          _binError == null &&
          _nameError == null) {
        widget.onSignUp?.call(
          SignUpData(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            organizationName: _organizationController.text.trim(),
            bin: normalizeBin(_binController.text),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CupertinoTextField(
          controller: _nameController,
          placeholder: 'Как вас зовут?',
          placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
          autofocus: true,
          keyboardType: TextInputType.text,
          clearButtonMode: OverlayVisibilityMode.editing,
          padding: const EdgeInsets.all(AppSpacing.md),
          enabled: !widget.isLoading,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.inputBorder,
              width: AppStroke.hairline,
            ),
            borderRadius: AppRadius.control,
          ),
        ),
        if (_nameError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _nameError!,
              style: AppTypography.footnote.copyWith(
                color: AppColors.error.resolveFrom(context),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        CupertinoTextField(
          controller: _emailController,
          placeholder: 'Email',
          autofocus: true,
          placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
          keyboardType: TextInputType.emailAddress,
          clearButtonMode: OverlayVisibilityMode.editing,
          padding: const EdgeInsets.all(AppSpacing.md),
          enabled: !widget.isLoading,
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
          controller: _organizationController,
          placeholder: 'Наименование организации',
          placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
          keyboardType: TextInputType.text,
          clearButtonMode: OverlayVisibilityMode.editing,
          maxLength: 255, // the API's limit: longer is a 400
          padding: const EdgeInsets.all(AppSpacing.md),
          enabled: !widget.isLoading,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.inputBorder,
              width: AppStroke.hairline,
            ),
            borderRadius: AppRadius.control,
          ),
        ),
        if (_organizationError != null) _fieldError(_organizationError!),
        const SizedBox(height: AppSpacing.md),
        CupertinoTextField(
          controller: _binController,
          placeholder: 'БИН',
          placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
          keyboardType: TextInputType.number,
          clearButtonMode: OverlayVisibilityMode.editing,
          padding: const EdgeInsets.all(AppSpacing.md),
          enabled: !widget.isLoading,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.inputBorder,
              width: AppStroke.hairline,
            ),
            borderRadius: AppRadius.control,
          ),
        ),
        if (_binError != null) _fieldError(_binError!),
        const SizedBox(height: AppSpacing.md),
        CupertinoTextField(
          controller: _passwordController,
          placeholder: 'Пароль',
          placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
          obscureText: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          enabled: !widget.isLoading,
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
        const SizedBox(height: AppSpacing.md),
        CupertinoTextField(
          controller: _passwordConfirmationController,
          placeholder: 'Подтверждение пароля',
          placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
          obscureText: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          enabled: !widget.isLoading,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.inputBorder,
              width: AppStroke.hairline,
            ),
            borderRadius: AppRadius.control,
          ),
        ),
        if (_passwordConfirmationError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _passwordConfirmationError!,
              style: AppTypography.footnote.copyWith(
                color: AppColors.error.resolveFrom(context),
              ),
            ),
          ),
        if (widget.errorMessage != null)
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Text(
              TranslationService.translate(widget.errorMessage!),
              style: AppTypography.footnote.copyWith(
                color: AppColors.error.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        CupertinoButton.filled(
          borderRadius: AppRadius.card,
          onPressed: widget.isLoading ? null : _validateAndSubmit,
          child: widget.isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Зарегистрироваться'),
        ),
      ],
    );
  }
}
