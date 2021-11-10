import 'package:flutter/cupertino.dart';
import 'package:prokurs/models/arguments/pointScreenArguments.dart';
import 'package:prokurs/widgets/pointCard.dart';

class PointPage extends StatelessWidget {
  static const routeName = '/point';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as PointScreenArguments;
    final exchangePoint = args.exchangePoint;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.fromSTEB(10, 5, 5, 5),
        leading: CupertinoButton(
          child: Text('Закрыть'),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: PointCard(point: exchangePoint),
      ),
    );
  }
}
