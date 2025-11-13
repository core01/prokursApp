import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/point/domain/models/point_screen_arguments.dart';
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
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: CupertinoPageScaffold(
        backgroundColor: DarkTheme.mainBlack,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: DarkTheme.mainBlack,
          // padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 5, 5),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                CupertinoIcons.arrow_left,
                size: 24,
                color: DarkTheme.generalWhite,
              ),
            ),
          ),
          middle: Column(
            children: [
              Container(
                child: Text(
                  exchangePoint.name,
                  overflow: TextOverflow.ellipsis,
                  style: Typography.body2.merge(const TextStyle(
                    color: DarkTheme.generalWhite,
                  )),
                ),
              ),
              Container(
                child: Text(
                  "Обновлено в $updateTime",
                  style: Typography.body3
                      .merge(const TextStyle(color: DarkTheme.darkSecondary)),
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
                color: DarkTheme.generalWhite,
                child: PointCard(point: exchangePoint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
