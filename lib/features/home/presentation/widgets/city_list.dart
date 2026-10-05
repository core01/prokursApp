import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';

/// The cities to choose from, popular ones first: inset grouped lists of tappable rows.
class CityList extends StatelessWidget {
  const CityList({
    super.key,
    required this.popular,
    required this.others,
    required this.onSelect,
  });

  final List<City> popular;
  final List<City> others;
  final ValueChanged<City> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final cities in [popular, others])
          if (cities.isNotEmpty)
            CupertinoListSection.insetGrouped(
              backgroundColor: AppColors.background,
              margin: sectionMargin,
              hasLeading: false,
              children: [
                for (final city in cities)
                  CupertinoListTile(
                    title: Text(city.title),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => onSelect(city),
                  ),
              ],
            ),
      ],
    );
  }
}
