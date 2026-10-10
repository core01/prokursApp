import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/profile/presentation/pages/profile_page.dart';

class MyPointsNavigationBar extends CupertinoNavigationBar {
  MyPointsNavigationBar({
    super.key,
    required String? userEmail,
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
                  onPressed: () => Navigator.of(context).pushNamed(ProfilePage.routeName),
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
