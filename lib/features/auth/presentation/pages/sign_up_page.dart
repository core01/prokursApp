import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/widgets/legal_documents_section.dart';
import 'package:prokurs/features/auth/data/services/auth_service.dart';
import 'package:prokurs/features/auth/presentation/forms/sign_up_form.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = '/sign-up';

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSignUp(SignUpData data) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
        fullName: data.fullName,
        email: data.email,
        password: data.password,
        organizationName: data.organizationName,
        bin: data.bin,
      );
      if (mounted) {
        Navigator.pop(
          context,
          SignUpResult(email: data.email, password: data.password),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Регистрация")),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: cardDecoration(context),
                  child: const Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle,
                        size: AppIconSize.regular,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Регистрация необходима для владельцев обменных пунктов. Если вы хотите добавить обменный пункт, заполните данные ниже.',
                          style: AppTypography.subheadline,
                        ),
                      ),
                    ],
                  ),
                ),
                SignUpForm(
                  onSignUp: _handleSignUp,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                ),
                // Registering is the acceptance: the owner sees what of, and can read it first.
                const SizedBox(height: AppSpacing.lg),
                const LegalDocumentsSection(
                  header: 'Регистрируясь, вы принимаете условия и даёте согласие:',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
