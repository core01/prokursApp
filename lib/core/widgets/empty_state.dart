import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';

/// What a screen shows instead of content it doesn't have: nothing yet, or a failed load.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Shows progress in the button while its action runs.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTypography.title3,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.secondaryLabel.resolveFrom(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              CupertinoButton.filled(
                borderRadius: AppRadius.card,
                onPressed: onAction,
                child: isLoading
                    ? CupertinoActivityIndicator(
                        color: AppColors.onAccent.resolveFrom(context),
                      )
                    : Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
