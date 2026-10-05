import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';

/// A value for CupertinoListTile.additionalInfo. The tile doesn't let it shrink, so it takes at
/// most half the row and ends with an ellipsis: large Dynamic Type sizes don't overflow the row.
class ListTileValue extends StatelessWidget {
  const ListTileValue(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width / 2,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: AppColors.secondaryLabel.resolveFrom(context)),
      ),
    );
  }
}
