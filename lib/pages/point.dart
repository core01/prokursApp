import 'package:flutter/cupertino.dart';
import 'package:prokurs/constants.dart';
import 'package:prokurs/models/arguments/point_screen_arguments.dart';
import 'package:prokurs/utils.dart';
import 'package:prokurs/widgets/point_card.dart';

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
        backgroundColor: DarkTheme.generalWhite,
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
        child: PointCard(point: exchangePoint),
      ),
    );
  }
}
