import 'package:flutter/cupertino.dart';
import 'package:prokurs/constants.dart';
import 'package:prokurs/pages/sign_up.dart';
import 'package:prokurs/providers/auth.dart';
import 'package:prokurs/services/translation_service.dart';
import 'package:prokurs/widgets/forms/sign_in_form.dart';
import 'package:prokurs/pages/my_points.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  static const routeName = '/sign-in';

  const SignInPage({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInPage> {
  bool _isRegistered = false;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleSignIn(String email, String password) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthProvider>().signIn(email, password);
      if (mounted) {
        // Redirect to My Points page after successful sign-in
        Navigator.of(context).pushReplacementNamed(MyPointsPage.routeName);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = TranslationService.translate(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSignUpResult(SignUpResult? result) {
    if (result != null) {
      setState(() {
        _isRegistered = true;
      });
      // Hide the message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isRegistered = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: DarkTheme.generalWhite,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: DarkTheme.mainBlack,
          // padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 5, 5),
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
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isRegistered)
                    AnimatedOpacity(
                      opacity: _isRegistered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: CupertinoColors.activeGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Успешная регистрация",
                              style: TextStyle(
                                color: CupertinoColors.activeGreen,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        Text(
                          "Вход в личный кабинет обменного пункта",
                          style: Typography.heading,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SignInForm(
                    onSignIn: _handleSignIn,
                    signInError: _errorMessage,
                    onSignUp: () {
                      if (mounted) {
                        Navigator.pushNamed(context, SignUpPage.routeName)
                            .then((result) {
                          _handleSignUpResult(result as SignUpResult?);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
