import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';

/// A message shown in place, next to what it is about, instead of an alert: problems the
/// screen itself lets the user resolve (Apple HIG, "Alerts" and "Feedback").
class InlineNotice extends StatelessWidget {
  const InlineNotice({
    super.key,
    required this.text,
    this.color = AppColors.error,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(this.color, context);

    // liveRegion: VoiceOver reads it out when it appears.
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: ShapeDecoration(
          color: color.withValues(alpha: 0.12),
          shape: const RoundedSuperellipseBorder(borderRadius: AppRadius.card),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CupertinoIcons.exclamationmark_circle_fill, color: color, size: AppIconSize.small),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: Text(text, style: AppTypography.subheadline)),
          ],
        ),
      ),
    );
  }
}
