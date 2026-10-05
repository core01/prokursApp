import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';

const _label = 'Есть оптовые курсы';

/// The warning color on its own 12% tint, as in InlineNotice. The label is semibold: on the
/// tint it reaches the 3:1 Apple asks of bold text, not the 4.5:1 of regular text.
Color _tint(Color color) => color.withValues(alpha: 0.12);

/// Marks an exchange point that sells at wholesale rates, in the rates table.
class WholesaleBadge extends StatelessWidget {
  const WholesaleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.warning.resolveFrom(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: _tint(color), borderRadius: AppRadius.capsule),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.cube_box,
              color: color,
              size: AppTypography.footnote.fontSize,
              applyTextScaling: true,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Flexible(
              child: Text(
                _label,
                style: AppTypography.footnote.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wholesale rates and their conditions, on the exchange point's screen.
class WholesaleNotice extends StatelessWidget {
  const WholesaleNotice({super.key, this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.warning.resolveFrom(context);
    final note = this.note?.trim() ?? '';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: ShapeDecoration(
        color: _tint(color),
        shape: const RoundedSuperellipseBorder(borderRadius: AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.cube_box, color: color, size: AppIconSize.small),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label,
                  style: AppTypography.subheadline.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(note, style: AppTypography.subheadline),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
