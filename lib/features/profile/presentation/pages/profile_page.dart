import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/exceptions/api_exception.dart';
import 'package:prokurs/core/exceptions/session_expired_exception.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/utils/verification_status.dart';
import 'package:prokurs/core/widgets/form_rows.dart';
import 'package:prokurs/core/widgets/inline_notice.dart';
import 'package:prokurs/core/widgets/legal_documents_section.dart';
import 'package:prokurs/core/widgets/list_tile_value.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:prokurs/features/profile/data/services/profile_service.dart';
import 'package:prokurs/features/profile/domain/models/user_profile.dart';
import 'package:prokurs/features/profile/presentation/forms/organization_form.dart';
import 'package:provider/provider.dart';

/// The account, the organization behind it (API v2), the documents and sign-out.
class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  /// The profile's service; a fake one in tests.
  final ProfileService? service;

  const ProfilePage({super.key, this.service});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileService _service = widget.service ?? ProfileService();

  UserProfile? _profile;
  OrganizationForm _form = const OrganizationForm();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _saved = false;
  String? _loadError;
  String? _saveError;

  // The labels share one column; the longest («Дата выдачи») wraps at large text sizes.
  static const _labelWidth = 120.0;

  final _organizationName = TextEditingController();
  final _bin = TextEditingController();
  final _legalAddress = TextEditingController();
  final _directorName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _licenseNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _organizationName.dispose();
    _bin.dispose();
    _legalAddress.dispose();
    _directorName.dispose();
    _contactPhone.dispose();
    _licenseNumber.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final profile = await _service.getProfile();
      if (!mounted) return;
      setState(() => _apply(profile));
    } on SessionExpiredException {
      // The app is on its way to the sign-in screen, which explains it.
    } catch (e) {
      debugPrint('Error loading the profile: $e');
      if (mounted) setState(() => _loadError = 'Не удалось загрузить профиль');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Takes the profile as the server has it: the form and the fields show it.
  void _apply(UserProfile profile) {
    _profile = profile;
    _form = OrganizationForm.fromProfile(profile);
    _organizationName.text = profile.organizationName;
    _bin.text = profile.bin;
    _legalAddress.text = profile.legalAddress;
    _directorName.text = profile.directorName;
    _contactPhone.text = profile.contactPhone;
    _licenseNumber.text = profile.licenseNumber;
  }

  void _edit(OrganizationForm form) => setState(() {
        _form = form;
        _saved = false;
      });

  Future<void> _save() async {
    final form = _form.markSubmitted();
    if (!form.isValid) {
      setState(() {
        _form = form;
        _saved = false;
        _saveError = 'Проверьте заполнение формы';
      });
      return;
    }

    setState(() {
      _form = form;
      _isSaving = true;
      _saved = false;
      _saveError = null;
    });
    try {
      final saved = await _service.saveOrganization(form.toInput());
      if (!mounted) return;
      setState(() {
        _apply(saved);
        _saved = true;
      });
    } on SessionExpiredException {
      // The app is on its way to the sign-in screen, which explains it.
    } catch (e) {
      if (mounted) {
        setState(() {
          // ApiException texts are localized; anything else is not meant for the user.
          _saveError =
              e is ApiException ? e.toString() : 'Не удалось сохранить организацию';
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// A field's error, once «Сохранить» was pressed.
  String? _shown(String? error) => _form.isSubmitted ? error : null;

  @override
  Widget build(BuildContext context) {
    final headerStyle = AppTypography.footnote.copyWith(
      color: AppColors.secondaryLabel.resolveFrom(context),
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        middle: Text('Профиль'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CupertinoActivityIndicator()),
              )
            else if (_profile == null)
              _buildLoadError()
            else
              ..._buildOrganization(_profile!, headerStyle),
            Padding(
              padding: sectionMargin,
              child: const LegalDocumentsSection(header: 'ДОКУМЕНТЫ'),
            ),
            CupertinoListSection.insetGrouped(
              margin: sectionMargin,
              backgroundColor: AppColors.background,
              children: [
                CupertinoListTile(
                  title: Text(
                    'Выйти',
                    style: TextStyle(color: AppColors.destructive.resolveFrom(context)),
                  ),
                  onTap: () => context.read<AuthProvider>().signOut(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadError() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InlineNotice(text: _loadError ?? 'Не удалось загрузить профиль'),
          CupertinoButton(onPressed: _load, child: const Text('Повторить')),
        ],
      ),
    );
  }

  List<Widget> _buildOrganization(UserProfile profile, TextStyle headerStyle) {
    final hasLicense = profile.licenseNumber.isNotEmpty || profile.licenseDate != null;

    return [
      CupertinoListSection.insetGrouped(
        margin: sectionMargin,
        backgroundColor: AppColors.background,
        header: Text('АККАУНТ', style: headerStyle),
        children: [
          CupertinoListTile(
            title: const Text('Email'),
            additionalInfo: ListTileValue(profile.username),
          ),
        ],
      ),
      CupertinoFormSection.insetGrouped(
        backgroundColor: AppColors.background,
        margin: sectionMargin,
        header: Text('ОРГАНИЗАЦИЯ', style: headerStyle),
        footer: Text(
          'Данные видны только вам и администрации. Если вы измените БИН, номер или '
          'дату лицензии, проверка пройдёт заново.',
          style: headerStyle,
        ),
        children: [
          FormFieldRow(
            label: 'Наименование',
            labelWidth: _labelWidth,
            error: _shown(_form.organizationNameError),
            child: formTextField(
              controller: _organizationName,
              placeholder: 'Наименование организации',
              maxLines: null,
              onChanged: (value) => _edit(_form.copyWith(organizationName: value)),
            ),
          ),
          FormFieldRow(
            label: 'БИН',
            labelWidth: _labelWidth,
            error: _shown(_form.binError),
            child: formTextField(
              controller: _bin,
              placeholder: '12 цифр',
              keyboardType: TextInputType.number,
              onChanged: (value) => _edit(_form.copyWith(bin: value)),
            ),
          ),
          FormFieldRow(
            label: 'Адрес',
            labelWidth: _labelWidth,
            error: _shown(_form.legalAddressError),
            child: formTextField(
              controller: _legalAddress,
              placeholder: 'Юридический адрес',
              maxLines: null,
              onChanged: (value) => _edit(_form.copyWith(legalAddress: value)),
            ),
          ),
          FormFieldRow(
            label: 'Руководитель',
            labelWidth: _labelWidth,
            error: _shown(_form.directorNameError),
            child: formTextField(
              controller: _directorName,
              placeholder: 'ФИО руководителя',
              maxLines: null,
              onChanged: (value) => _edit(_form.copyWith(directorName: value)),
            ),
          ),
          FormFieldRow(
            label: 'Телефон',
            labelWidth: _labelWidth,
            error: _shown(_form.contactPhoneError),
            child: formTextField(
              controller: _contactPhone,
              placeholder: '+7 701 123 4567',
              keyboardType: TextInputType.phone,
              onChanged: (value) => _edit(_form.copyWith(contactPhone: value)),
            ),
          ),
          FormFieldRow(
            label: 'Лицензия',
            labelWidth: _labelWidth,
            error: _shown(_form.licenseNumberError),
            child: formTextField(
              controller: _licenseNumber,
              placeholder: 'Номер лицензии',
              onChanged: (value) => _edit(_form.copyWith(licenseNumber: value)),
            ),
          ),
          FormDateRow(
            label: 'Дата выдачи',
            labelWidth: _labelWidth,
            value: _form.licenseDate,
            error: _shown(_form.licenseDateError),
            onChanged: (value) => _edit(value == null
                ? _form.copyWith(clearLicenseDate: true)
                : _form.copyWith(licenseDate: value)),
          ),
          // The check belongs to the saved license, not to what is being typed.
          if (hasLicense)
            CupertinoListTile(
              title: const Text('Проверка лицензии'),
              additionalInfo: ListTileValue(verificationStatusLabel(profile.licenseStatus)),
            ),
        ],
      ),
      if (_saveError != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
          child: InlineNotice(text: _saveError!),
        ),
      if (_saved)
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
          child: Semantics(
            liveRegion: true,
            child: Text('Сохранено', textAlign: TextAlign.center, style: headerStyle),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
        child: CupertinoButton.filled(
          borderRadius: AppRadius.card,
          onPressed: _isSaving ? null : _save,
          child: const Text('Сохранить'),
        ),
      ),
    ];
  }
}
