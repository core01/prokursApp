import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/exceptions/api_exception.dart';
import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:prokurs/features/profile/data/services/profile_service.dart';
import 'package:prokurs/features/profile/domain/models/user_profile.dart';
import 'package:prokurs/features/profile/presentation/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The order of the page's text fields.
const _nameField = 0;
const _binField = 1;
const _phoneField = 4;

const _invalidBin = 'Неверный БИН: проверьте все 12 цифр';

/// The service without a network: what it holds is "the server's" copy.
class _FakeProfileService extends ProfileService {
  _FakeProfileService(this.profile);

  UserProfile profile;

  /// Thrown by the next load / every save.
  Object? loadError;
  Object? saveError;

  final saved = <UpdateOrganizationInput>[];

  @override
  Future<UserProfile> getProfile() async {
    final error = loadError;
    if (error != null) {
      loadError = null;
      throw error;
    }
    return profile;
  }

  @override
  Future<UserProfile> saveOrganization(UpdateOrganizationInput input) async {
    final error = saveError;
    if (error != null) throw error;
    saved.add(input);
    // The server stores what it was sent.
    return profile = UserProfile(
      username: profile.username,
      organizationName: input.organizationName ?? '',
      bin: input.bin ?? '',
      legalAddress: input.legalAddress ?? '',
      directorName: input.directorName ?? '',
      contactPhone: input.contactPhone ?? '',
      licenseNumber: input.licenseNumber ?? '',
      licenseDate: input.licenseDate,
    );
  }
}

/// Signing out revokes the refresh token on the network: here it only says it was asked.
class _RecordingAuth extends AuthProvider {
  bool signedOut = false;

  @override
  Future<void> signOut() async => signedOut = true;
}

UserProfile _profile({String licenseStatus = 'unverified', bool license = true}) => UserProfile(
      username: 'owner@mail.kz',
      organizationName: 'ТОО «Обмен»',
      bin: '971240001315',
      licenseNumber: license ? '12-34' : '',
      licenseDate: license ? DateTime(2024, 3, 5) : null,
      licenseStatus: licenseStatus,
    );

Future<void> _open(
  WidgetTester tester,
  ProfileService service, {
  AuthProvider? auth,
}) async {
  // Tall, so the whole page is built: the list builds lazily.
  tester.view.physicalSize = const Size(1179, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: auth ?? AuthProvider(),
    child: CupertinoApp(theme: appTheme, home: ProfilePage(service: service)),
  ));
  await tester.pumpAndSettle();
}

Finder _field(int index) => find.byType(CupertinoTextField).at(index);

String _text(WidgetTester tester, int index) =>
    tester.widget<CupertinoTextField>(_field(index)).controller!.text;

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text('Сохранить'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the account and the organization as the server has them', (tester) async {
    await _open(tester, _FakeProfileService(_profile()));

    expect(find.text('owner@mail.kz'), findsOneWidget);
    expect(_text(tester, _nameField), 'ТОО «Обмен»');
    expect(_text(tester, _binField), '971240001315');
    expect(find.text('05.03.2024'), findsOneWidget);
    expect(find.text('Проверка лицензии'), findsOneWidget);
    expect(find.text('Ожидает проверки'), findsOneWidget);
  });

  testWidgets('the check of the license reads as the administration decided', (tester) async {
    await _open(tester, _FakeProfileService(_profile(licenseStatus: 'verified')));

    expect(find.text('Подтверждено'), findsOneWidget);
  });

  testWidgets('without a license there is nothing to check', (tester) async {
    await _open(tester, _FakeProfileService(_profile(license: false)));

    expect(find.text('Проверка лицензии'), findsNothing);
    expect(find.text('Не указана'), findsOneWidget);
  });

  testWidgets('a wrong БИН is pointed out on saving and nothing is sent', (tester) async {
    final service = _FakeProfileService(_profile());
    await _open(tester, service);

    await tester.enterText(_field(_binField), '240540000700');
    await tester.pump();
    // Errors wait for the first press of «Сохранить».
    expect(find.text(_invalidBin), findsNothing);

    await _save(tester);

    expect(find.text(_invalidBin), findsOneWidget);
    expect(find.text('Проверьте заполнение формы'), findsOneWidget);
    expect(service.saved, isEmpty);
    expect(find.text('Сохранено'), findsNothing);
  });

  testWidgets('saves cleaned values and shows what the server stored', (tester) async {
    final service = _FakeProfileService(_profile());
    await _open(tester, service);

    await tester.enterText(_field(_nameField), 'ТОО «Новое»');
    await tester.enterText(_field(_binField), '9401 4000 0385');
    await tester.enterText(_field(_phoneField), '+7 (701) 123-45-67');
    await _save(tester);

    final json = service.saved.single.toJson();
    expect(json['organizationName'], 'ТОО «Новое»');
    expect(json['bin'], '940140000385');
    expect(json['contactPhone'], '+77011234567');
    expect(find.text('Сохранено'), findsOneWidget);
    expect(_text(tester, _binField), '940140000385');
    expect(_text(tester, _phoneField), '+77011234567');
  });

  testWidgets('a cleared license date is sent as null, not left out', (tester) async {
    final service = _FakeProfileService(_profile());
    await _open(tester, service);

    await tester.tap(find.text('05.03.2024'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Очистить'));
    await tester.pumpAndSettle();
    expect(find.text('Не указана'), findsOneWidget);

    await _save(tester);

    final json = service.saved.single.toJson();
    expect(json.containsKey('licenseDate'), isTrue);
    expect(json['licenseDate'], isNull);
  });

  testWidgets("the API's validation error is shown above the button", (tester) async {
    final service = _FakeProfileService(_profile());
    final options = RequestOptions(path: '/v2/profile/organization');
    service.saveError = ApiException.fromDio(DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 400, data: {
        'message': ['bin must be a valid БИН'],
        'errors': [
          {'field': 'bin', 'constraint': 'isBin'},
        ],
      }),
    ));
    await _open(tester, service);

    await _save(tester);

    expect(find.text('БИН: неверный БИН, проверьте все 12 цифр'), findsOneWidget);
    expect(find.text('Сохранено'), findsNothing);
    // What was typed stays, so it can be fixed.
    expect(_text(tester, _nameField), 'ТОО «Обмен»');
  });

  testWidgets('an unexpected failure to save says so in plain words', (tester) async {
    final service = _FakeProfileService(_profile())..saveError = StateError('boom');
    await _open(tester, service);

    await _save(tester);

    expect(find.text('Не удалось сохранить организацию'), findsOneWidget);
  });

  testWidgets('a failed load can be retried, and sign-out stays reachable', (tester) async {
    final service = _FakeProfileService(_profile())..loadError = StateError('offline');
    await _open(tester, service);

    expect(find.text('Не удалось загрузить профиль'), findsOneWidget);
    expect(find.text('Выйти'), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsNothing);

    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();

    expect(find.text('Не удалось загрузить профиль'), findsNothing);
    expect(_text(tester, _nameField), 'ТОО «Обмен»');
  });

  testWidgets('lists the documents', (tester) async {
    await _open(tester, _FakeProfileService(_profile()));

    expect(find.text('Политика конфиденциальности'), findsOneWidget);
    expect(find.text('Пользовательское соглашение'), findsOneWidget);
  });

  testWidgets('«Выйти» signs the user out', (tester) async {
    final auth = _RecordingAuth();
    await _open(tester, _FakeProfileService(_profile()), auth: auth);

    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();

    expect(auth.signedOut, isTrue);
  });
}
