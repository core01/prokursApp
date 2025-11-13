import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/features/auth/data/services/auth_service.dart';
import 'package:prokurs/features/auth/presentation/forms/sign_up_form.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = '/sign-up';

  const SignUpPage({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSignUp(
      String fullName, String email, String password) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
          fullName: fullName, email: email, password: password);
      if (mounted) {
        Navigator.pop(context, SignUpResult(email: email, password: password));
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
        backgroundColor: DarkTheme.generalWhite,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: DarkTheme.mainBlack,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                CupertinoIcons.arrow_left,
                size: 24,
                color: DarkTheme.generalWhite,
              ),
            ),
          ),
          middle: Text(
            "Регистрация",
            style: Typography.heading2
                .merge(const TextStyle(color: DarkTheme.generalBlack)),
            textAlign: TextAlign.center,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: DarkTheme.lightSecondary.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: DarkTheme.lightSecondary),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.info_circle,
                            color: DarkTheme.generalBlack,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Регистрация необходима для владельцев обменных пунктов. Если вы хотите добавить обменный пункт, заполните данные ниже.',
                              style: TextStyle(
                                color: DarkTheme.generalBlack,
                                fontSize: 14,
                              ),
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
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
