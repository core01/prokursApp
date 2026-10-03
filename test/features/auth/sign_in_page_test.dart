import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/features/auth/domain/models/auth_tokens.dart';
import 'package:prokurs/features/auth/presentation/pages/sign_in_page.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A JWT whose payload is {"username":"owner@mail.kz"}; the signature isn't checked.
const _accessToken = 'x.eyJ1c2VybmFtZSI6Im93bmVyQG1haWwua3oifQ.x';

Widget _app(AuthProvider authProvider) => ChangeNotifierProvider.value(
      value: authProvider,
      child: const CupertinoApp(home: SignInPage()),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('after the session expired: notice and the email prefilled', (tester) async {
    final authProvider = AuthProvider();
    await authProvider.updateTokens(
        AuthTokens(accessToken: _accessToken, refreshToken: 'r'));
    await authProvider.expireSession();

    await tester.pumpWidget(_app(authProvider));

    expect(find.text('Сессия истекла. Войдите снова, чтобы продолжить'), findsOneWidget);
    expect(find.text('owner@mail.kz'), findsOneWidget);

    // Shown once: opening the screen again later doesn't repeat it.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(authProvider));
    expect(find.text('Сессия истекла. Войдите снова, чтобы продолжить'), findsNothing);
  });

  testWidgets('a regular sign-in has no notice', (tester) async {
    await tester.pumpWidget(_app(AuthProvider()));

    expect(find.text('Сессия истекла. Войдите снова, чтобы продолжить'), findsNothing);
  });
}
