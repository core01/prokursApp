import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prokurs/constants.dart';
import 'package:prokurs/models/exchangePoint.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:intl/intl.dart';

class PointCard extends StatelessWidget {
  final ExchangePoint point;

  const PointCard({required this.point});

  List<TableRow> buildRatesTableRows() {
    String getBuyKey(currency) => 'buy$currency';
    String getSellKey(currency) => 'sell$currency';

    return <TableRow>[
      TableRow(
        children: [
          TableCell(
            child: Container(
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
      ...CURRENCY_LIST.map((currency) {
        num buyValue = point.get(getBuyKey(currency['id']));
        num sellValue = point.get(getSellKey(currency['id']));

        return TableRow(
          children: [
            TableCell(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(currency['label']),
                      Icon(
                        currency['icon'],
                        color: CupertinoColors.systemGrey,
                      ),
                    ]),
              ),
            ),
            TableCell(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Text(buyValue != 0 ? buyValue.toString() : '-'),
              ),
            ),
            TableCell(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Text(sellValue != 0 ? sellValue.toString() : '-'),
              ),
            ),
          ],
        );
      }),
    ];
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
              child: Text(point.info != null ? '${point.info}' : '-'),
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
              child: point.phones != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...point.phones.map((phone) {
                          return CupertinoButton(
                            minSize: 0.5,
                            padding: EdgeInsets.all(5),
                            onPressed: () async {
                              await UrlLauncher.launch('tel://$phone');
                            },
                            child: Text(
                              phone,
                              style: TextStyle(fontSize: 14),
                            ),
                          );
                        })
                      ],
                    )
                  : Text('-'),
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
              child: Text(
                DateFormat('dd.MM.yyyy  HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    point.date_update * 1000 as int,
                  ),
                ),
              ),
            ),
            Table(
              border: TableBorder.all(
                width: 1,
                color: CupertinoColors.systemGrey6,
              ),
              defaultColumnWidth: FractionColumnWidth(0.25),
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
