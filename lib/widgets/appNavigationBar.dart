import 'package:flutter/cupertino.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar(this._title);

  final String _title;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverNavigationBar(
      border: Border.all(color: CupertinoColors.white),
      backgroundColor: CupertinoColors.white,
      largeTitle: Text(_title),
      middle: Text(_title),
      previousPageTitle: 'Back',
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: const Icon(
                CupertinoIcons.info,
                color: CupertinoColors.black,
                size: 32,
              ),
              onPressed: () {
                print('ON BUTTON CLICK');
              }),
        ],
      ),
    );
  }
}
