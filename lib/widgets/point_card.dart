import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/constants.dart';
import 'package:prokurs/models/exchange_point.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

class PointCard extends StatelessWidget {
  final ExchangePoint point;

  const PointCard({required this.point});

  String getPointCurrencyBuyValue(String currencyId) {
    return getPointCurrencyRateStringFormatted(this.point, '$BUY_KEY$currencyId');
  }

  String getPointCurrencySellValue(String currencyId) {
    return getPointCurrencyRateStringFormatted(this.point, '$SELL_KEY$currencyId');
  }

  Widget get getPointDateUpdate => Text(
        DateFormat('dd.MM.yyyy  HH:mm:ss').format(
          DateTime.fromMillisecondsSinceEpoch(
            this.point.date_update * 1000 as int,
          ),
        ),
      );

  Widget get buildPointPhones => point.phones != null
      ? Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...point.phones.map((phone) {
              return CupertinoButton(
                minSize: 0.5,
                padding: EdgeInsets.all(5),
                onPressed: () => _launchPhone(phone),
                child: Text(phone),
              );
            })
          ],
        )
      : Text('-');

  Widget get buildPointInfo => Text(
        point.info != null ? '${point.info}' : '-',
      );

  List<TableRow> buildRatesTableRows() {
    return <TableRow>[
      TableRow(
        children: [
          TableCell(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: Text(
                'Валюта',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          TableCell(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: Text(
                'Покупка',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          TableCell(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: Text(
                'Продажа',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      ...CURRENCY_LIST.map((currency) => TableRow(
            children: [
              TableCell(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          currency.label,
                        ),
                      ),
                      Container(
                        child: Icon(
                          currency.icon,
                          color: CupertinoColors.systemGrey2,
                        ),
                        padding: EdgeInsets.only(left: 10),
                      ),
                    ],
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text(this.getPointCurrencyBuyValue(currency.id)),
                ),
              ),
              TableCell(
                child: Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text(this.getPointCurrencySellValue(currency.id)),
                ),
              ),
            ],
          )),
    ];
  }

  void _launchPhone(phone) async {
    final Uri phoneLink = Uri.parse('tel://${phone.replaceAll(new RegExp("[^\\d+]"), "")}');

    if (await canLaunchUrl(phoneLink)) {
      await launchUrl(phoneLink);
      debugPrint('Launching $phoneLink');
    } else {
      debugPrint('Can\'t launch $phoneLink');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text(
                point.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              margin: EdgeInsets.only(bottom: 15),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Text(
                'Информация:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: this.buildPointInfo,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Text(
                'Телефоны:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: this.buildPointPhones,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Text(
                'Время обновления:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: this.getPointDateUpdate,
            ),
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: CupertinoColors.systemGrey6,
                  width: 1,
                ),
                verticalInside: BorderSide(
                  color: CupertinoColors.systemGrey6,
                  width: 1,
                ),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                ...buildRatesTableRows(),
              ],
            )
          ],
        ),
      ),
      padding: EdgeInsets.all(10),
    );
  }
}
