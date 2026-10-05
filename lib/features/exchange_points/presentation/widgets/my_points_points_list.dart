import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/widgets/empty_state.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/exchange_points/presentation/widgets/currency_rates_table.dart';

class MyPointsPointsList extends StatelessWidget {
  const MyPointsPointsList({
    super.key,
    required this.points,
    required this.errorMessage,
    required this.isLoading,
    required this.onRefresh,
    required this.onRetry,
    required this.onEdit,
    required this.onDelete,
    required this.formatDateTime,
  });

  final List<ExchangePoint> points;
  final String? errorMessage;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetry;
  final void Function(ExchangePoint point) onEdit;
  final Future<void> Function(num id) onDelete;
  final String Function(num timestamp) formatDateTime;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: onRefresh),
        if (errorMessage != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: 'Упс! Что-то пошло не так',
              message: errorMessage,
              actionLabel: 'Повторить',
              onAction: onRetry,
              isLoading: isLoading,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final point = points[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ExchangePointListItem(
                    point: point,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    formatDateTime: formatDateTime,
                  ),
                );
              }, childCount: points.length),
            ),
          ),
      ],
    );
  }
}

class ExchangePointListItem extends StatelessWidget {
  const ExchangePointListItem({
    super.key,
    required this.point,
    required this.onEdit,
    required this.onDelete,
    required this.formatDateTime,
  });

  final ExchangePoint point;
  final void Function(ExchangePoint point) onEdit;
  final Future<void> Function(num id) onDelete;
  final String Function(num timestamp) formatDateTime;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(point.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: ShapeDecoration(
          color: AppColors.destructive.resolveFrom(context),
          shape: const RoundedSuperellipseBorder(borderRadius: AppRadius.card),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(CupertinoIcons.delete, color: AppColors.onDestructive),
      ),
      onDismissed: (direction) async {
        await onDelete(point.id);
      },
      // A choice about an action the user started: an action sheet, not an alert (Apple HIG).
      confirmDismiss: (direction) async {
        return await showCupertinoModalPopup<bool>(
              context: context,
              builder: (context) => CupertinoActionSheet(
                title: const Text('Удалить обменный пункт?'),
                actions: [
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Удалить'),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Отмена'),
                ),
              ),
            ) ??
            false;
      },
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        foregroundColor: AppColors.label.resolveFrom(context),
        onPressed: () => onEdit(point),
        child: ExchangePointCard(point: point, formatDateTime: formatDateTime),
      ),
    );
  }
}

class ExchangePointCard extends StatelessWidget {
  const ExchangePointCard({
    super.key,
    required this.point,
    required this.formatDateTime,
  });

  final ExchangePoint point;
  final String Function(num timestamp) formatDateTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(context),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(point.name, style: AppTypography.headline),
          const SizedBox(height: AppSpacing.xxs),
          Text(point.info ?? '', style: AppTypography.subheadline),
          const SizedBox(height: AppSpacing.sm),
          CurrencyRatesTable(point: point, formatDateTime: formatDateTime),
        ],
      ),
    );
  }
}
