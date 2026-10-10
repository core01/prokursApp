import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/point/presentation/navigation/point_screen_arguments.dart';
import 'package:prokurs/features/point/presentation/widgets/point_card.dart';

class PointPage extends StatelessWidget {
  static const routeName = '/point';

  const PointPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as PointScreenArguments;
    final exchangePoint = args.exchangePoint;
    var datetime = DateTime.fromMillisecondsSinceEpoch(
        exchangePoint.dateUpdate.toInt() * 1000);

    var updateTime = getUpdateTime(datetime);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.surface,
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        backgroundColor: AppColors.header,
        // The standard back button, in the header's color.
        leading: const CupertinoNavigationBarBackButton(color: AppColors.onHeader),
        middle: Column(
          children: [
            Text(
              exchangePoint.name,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headline.copyWith(color: AppColors.onHeader),
            ),
            Text(
              "Обновлено в $updateTime",
              style: AppTypography.footnote.copyWith(color: AppColors.onHeaderSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      child: PointCard(point: exchangePoint),
    );
  }
}
