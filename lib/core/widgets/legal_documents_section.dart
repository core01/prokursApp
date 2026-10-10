import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/utils/utils.dart';

/// A legal document of the service, which lives on the site under [path].
class LegalDocument {
  const LegalDocument(this.title, this.path);

  final String title;
  final String path;

  Uri get url => Uri.https(legalHost, path);
}

/// Where the documents are published: the same pages the web links (`LEGAL_ROUTES`).
const legalHost = 'prokurs.kz';

/// What registering accepts: the terms and the placement agreement, and the consent to the
/// processing of personal data on the terms of the privacy policy.
const registrationDocuments = [
  LegalDocument('Пользовательское соглашение', '/terms'),
  LegalDocument('Соглашение о размещении обменного пункта', '/offer'),
  LegalDocument('Политика конфиденциальности', '/privacy-policy'),
  LegalDocument('Согласие на обработку персональных данных', '/personal-data-consent'),
];

/// The documents as tappable rows (44 pt targets, a chevron), under an optional [header].
/// A row opens the page on the site; if that can't be done, a dialog says so.
class LegalDocumentsSection extends StatelessWidget {
  const LegalDocumentsSection({
    super.key,
    this.header,
    this.documents = registrationDocuments,
  });

  final String? header;
  final List<LegalDocument> documents;

  Future<void> _open(BuildContext context, LegalDocument document) async {
    try {
      await openUrl(url: document.url.toString());
    } catch (_) {
      if (!context.mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Не удалось открыть документ'),
          content: Text('Он доступен по адресу ${document.url}'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      margin: EdgeInsets.zero,
      backgroundColor: AppColors.background,
      header: header == null
          ? null
          : Text(
              header!,
              style: AppTypography.footnote.copyWith(
                color: AppColors.secondaryLabel.resolveFrom(context),
              ),
            ),
      children: [
        for (final document in documents)
          CupertinoListTile(
            title: Text(document.title),
            trailing: const CupertinoListTileChevron(),
            onTap: () => _open(context, document),
          ),
      ],
    );
  }
}
