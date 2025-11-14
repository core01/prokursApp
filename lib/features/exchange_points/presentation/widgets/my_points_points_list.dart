import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
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
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          builder:
              (
                context,
                refreshState,
                pulledExtent,
                refreshTriggerPullDistance,
                refreshIndicatorExtent,
              ) {
                return const Center(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 15.0,
                        bottom: 15.0,
                        left: 0.0,
                        right: 0.0,
                        child: CupertinoActivityIndicator(
                          color: DarkTheme.mainBlack,
                          radius: 14.0,
                        ),
                      ),
                    ],
                  ),
                );
              },
        ),
        if (errorMessage != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MyPointsErrorSection(
                errorMessage: errorMessage!,
                isLoading: isLoading,
                onRetry: onRetry,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final point = points[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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

class MyPointsErrorSection extends StatelessWidget {
  const MyPointsErrorSection({
    super.key,
    required this.errorMessage,
    required this.isLoading,
    required this.onRetry,
  });

  final String errorMessage;
  final bool isLoading;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Упс! Что-то пошло не так",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage,
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: DarkTheme.generalBlack,
          onPressed: () {
            onRetry();
          },
          child: isLoading
              ? const CupertinoActivityIndicator(
                  color: DarkTheme.generalWhite,
                  radius: 14.0,
                )
              : const Text("Повторить"),
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
        color: CupertinoColors.destructiveRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
      ),
      onDismissed: (direction) async {
        await onDelete(point.id);
      },
      confirmDismiss: (direction) async {
        return await showCupertinoDialog<bool>(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Удалить обменный пункт?'),
                content: const Text(
                  'Вы уверены, что хотите удалить этот обменный пункт?',
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text(
                      'Отмена',
                      style: TextStyle(color: DarkTheme.generalBlack),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text('Удалить'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: GestureDetector(
        onTap: () => onEdit(point),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DarkTheme.generalWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              point.name,
              style: Typography.body2.merge(
                const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Text(point.info ?? '', style: Typography.body3),
            const SizedBox(height: 12),
            CurrencyRatesTable(point: point, formatDateTime: formatDateTime),
          ],
        ),
      ),
    );
  }
}
