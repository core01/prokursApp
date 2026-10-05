import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/theme/app_theme.dart';

void main() {
  // On push, the navigation bar morphs the previous title into the back button, interpolating
  // the theme's title and action styles: they must be interpolatable (same `inherit`).
  for (final (name, Widget previousBar) in [
    ('title', const CupertinoNavigationBar(middle: Text('Курсы'))),
    ('large title', const CupertinoNavigationBar.large(largeTitle: Text('Выберите город'))),
  ]) {
    testWidgets('the $name animates into the back button of the next screen',
        (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(CupertinoApp(
        navigatorKey: navigator,
        theme: appTheme,
        home: CupertinoPageScaffold(
          navigationBar: previousBar as ObstructingPreferredSizeWidget,
          child: const SizedBox(),
        ),
      ));

      navigator.currentState!.push(CupertinoPageRoute(
        title: 'Курсы',
        builder: (_) => const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('О приложении')),
          child: SizedBox(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('О приложении'), findsOneWidget);
    });
  }
}
