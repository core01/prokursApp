import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
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
        exchangePoint.date_update.toInt() * 1000);

    var updateTime = getUpdateTime(datetime);


final theme = CupertinoTheme.of(context);
    final Color themePrimaryContrastingColor = CupertinoDynamicColor.resolve(theme.primaryContrastingColor, context);
    final Color themePrimaryColor = CupertinoDynamicColor.resolve(theme.primaryColor, context);
    final Color themeScaffoldBackgroundColor = CupertinoDynamicColor.resolve(theme.scaffoldBackgroundColor, context);
    final Color themeBarBackgroundColor = CupertinoDynamicColor.resolve(theme.barBackgroundColor, context);
    

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: CupertinoPageScaffold(
        backgroundColor: themeScaffoldBackgroundColor,
        navigationBar: CupertinoNavigationBar(
          automaticBackgroundVisibility: false,
          backgroundColor: themeBarBackgroundColor,
          // padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 5, 5),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                CupertinoIcons.arrow_left,
                size: 24,
                color: AppColors.generalWhite,
              ),
            ),
          ),
          middle: Column(
            children: [
              Container(
                child: Text(
                  exchangePoint.name,
                  overflow: TextOverflow.ellipsis,
                  style: Typography.body2.merge(TextStyle(color: AppColors.generalWhite,
                  )),
                ),
              ),
              Container(
                child: Text(
                  "Обновлено в $updateTime",
                  style: Typography.body3
                      .merge(const TextStyle(color: AppColors.darkSecondary)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: themePrimaryContrastingColor,
                child: PointCard(point: exchangePoint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
