import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/auth/presentation/forms/sign_up_form.dart';
import 'package:prokurs/features/auth/presentation/pages/sign_up_page.dart';

const _required = 'Поле обязательно для заполнения';
const _invalidBin = 'Неверный БИН: проверьте все 12 цифр';

Future<void> _pump(WidgetTester tester, Widget home) async {
  // Tall, so the whole page is on the screen.
  tester.view.physicalSize = const Size(1179, 4000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(CupertinoApp(theme: appTheme, home: home));
  await tester.pumpAndSettle();
}

Widget _form(void Function(SignUpData data) onSignUp) => CupertinoPageScaffold(
      child: SafeArea(
        child: SingleChildScrollView(child: SignUpForm(onSignUp: onSignUp)),
      ),
    );

Future<void> _enter(WidgetTester tester, String placeholder, String text) =>
    tester.enterText(find.widgetWithText(CupertinoTextField, placeholder), text);

Future<void> _fill(WidgetTester tester, {String bin = '971240001315'}) async {
  await _enter(tester, 'Как вас зовут?', 'Айдос');
  await _enter(tester, 'Email', 'owner@mail.kz');
  await _enter(tester, 'Наименование организации', '  ТОО «Обмен» ');
  await _enter(tester, 'БИН', bin);
  await _enter(tester, 'Пароль', 'secret1');
  await _enter(tester, 'Подтверждение пароля', 'secret1');
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.text('Зарегистрироваться'));
  await tester.pumpAndSettle();
}

void main() {
  group('the sign-up form', () {
    testWidgets('asks for the organization and the БИН too', (tester) async {
      SignUpData? data;
      await _pump(tester, _form((d) => data = d));

      await _submit(tester);

      // The name, the email, the organization, the БИН and the password.
      expect(find.text(_required), findsNWidgets(5));
      expect(data, isNull);
    });

    testWidgets('a БИН with a wrong check digit is not let through', (tester) async {
      SignUpData? data;
      await _pump(tester, _form((d) => data = d));

      await _fill(tester, bin: '240540000700');
      await _submit(tester);

      expect(find.text(_invalidBin), findsOneWidget);
      expect(data, isNull);
    });

    testWidgets('hands over the cleaned organization and БИН', (tester) async {
      SignUpData? data;
      await _pump(tester, _form((d) => data = d));

      await _fill(tester, bin: '9712 4000 1315');
      await _submit(tester);

      expect(find.text(_invalidBin), findsNothing);
      expect(data, isNotNull);
      expect(data!.organizationName, 'ТОО «Обмен»');
      expect(data!.bin, '971240001315');
      expect(data!.email, 'owner@mail.kz');
    });
  });

  group('the sign-up page', () {
    testWidgets('says registering accepts the documents, and lists them', (tester) async {
      await _pump(tester, const SignUpPage());

      expect(find.text('Регистрируясь, вы принимаете условия и даёте согласие:'), findsOneWidget);
      for (final title in [
        'Пользовательское соглашение',
        'Соглашение о размещении обменного пункта',
        'Политика конфиденциальности',
        'Согласие на обработку персональных данных',
      ]) {
        expect(find.text(title), findsOneWidget);
      }
    });

    testWidgets("a document that can't be opened gives its address", (tester) async {
      // No url_launcher in tests: opening fails, as it would on a device without a browser.
      await _pump(tester, const SignUpPage());

      await tester.tap(find.text('Политика конфиденциальности'));
      // The launcher answers through the engine, in real time, not in the test's fake one.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();

      expect(find.text('Не удалось открыть документ'), findsOneWidget);
      expect(find.text('Он доступен по адресу https://prokurs.kz/privacy-policy'), findsOneWidget);
    });
  });
}
