import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';

class MyPointsNavigationBar extends CupertinoNavigationBar {
  MyPointsNavigationBar({
    super.key,
    required String? userEmail,
    required Future<void> Function() onSignOut,
    required VoidCallback onAdd,
  }) : super(
          backgroundColor: AppColors.background,
          middle: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Мои пункты"),
              if (userEmail != null)
                Builder(
                  builder: (context) => Text(
                    userEmail,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ),
            ],
          ),
          // Actions on the trailing side; the leading one is the standard back button.
          trailing: Builder(
            builder: (context) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => showCupertinoModalPopup(
                    context: context,
                    builder: (context) => CupertinoActionSheet(
                      title: const Text('Профиль пользователя'),
                      message: Text(userEmail ?? 'Не авторизован'),
                      actions: [
                        CupertinoActionSheetAction(
                          onPressed: () async {
                            Navigator.pop(context);
                            await onSignOut();
                          },
                          isDestructiveAction: true,
                          child: const Text('Выйти'),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.person_circle,
                    size: AppIconSize.regular,
                    semanticLabel: 'Профиль',
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onAdd,
                  child: const Icon(
                    CupertinoIcons.add,
                    size: AppIconSize.regular,
                    semanticLabel: 'Добавить пункт',
                  ),
                ),
              ],
            ),
          ),
        );
}
