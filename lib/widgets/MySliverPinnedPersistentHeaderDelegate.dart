import 'dart:io' show Platform;

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';

class MySliverPinnedPersistentHeaderDelegate
    extends SliverPinnedPersistentHeaderDelegate {
  MySliverPinnedPersistentHeaderDelegate({
    required super.minExtentProtoType,
    required super.maxExtentProtoType,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, double? minExtent,
      double maxExtent, bool overlapsContent) {
    var isMinExtentPrototypeVisible =
        shrinkOffset + (Platform.isAndroid ? -5 : 30) >= minExtent!;

    return DefaultTextStyle.merge(
      style: const TextStyle(
        color: CupertinoColors.white,
      ),
      child:
          isMinExtentPrototypeVisible ? minExtentProtoType : maxExtentProtoType,
    );
  }

  @override
  bool shouldRebuild(SliverPinnedPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
