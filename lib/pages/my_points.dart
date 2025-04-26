import 'package:flutter/cupertino.dart';
import 'package:prokurs/constants.dart';
import 'package:prokurs/models/exchange_point.dart';
import 'package:prokurs/pages/add_exchange_point.dart';
import 'package:prokurs/services/exchange_points_service.dart';

class MyPointsPage extends StatefulWidget {
  static const routeName = '/my-points';

  const MyPointsPage({super.key});

  @override
  _MyPointsState createState() => _MyPointsState();
}

class _MyPointsState extends State<MyPointsPage> {
  bool _isLoading = true;
  String? _errorMessage;
  final List<ExchangePoint> _points = [];
  final ExchangePointsService _exchangePointsService = ExchangePointsService();

  @override
  void initState() {
    super.initState();
    _getExchangePoints();
  }

  Future<void> _getExchangePoints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch user's exchange points
      final points = await _exchangePointsService.getMyExchangePointsList();
      if (mounted) {
        setState(() {
          _points.clear();
          _points.addAll(points);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load exchange points: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _showAddPointForm() {
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => AddExchangePointPage(
          exchangePoint: null, // null for new point
        ),
      ),
    )
        .then((exchangePointData) {
      if (exchangePointData != null) {
        _getExchangePoints(); // Refresh the list from API
      }
    });
  }

  void _editExchangePoint(ExchangePoint point) {
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => AddExchangePointPage(
          exchangePoint: point,
        ),
      ),
    )
        .then((updatedPoint) {
      if (updatedPoint != null) {
        _getExchangePoints(); // Refresh the list from API
      }
    });
  }

  Future<void> _deleteExchangePoint(num id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _exchangePointsService.deleteExchangePoint(id);

      if (mounted) {
        _getExchangePoints(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Не удалось удалить обменный пункт: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: DarkTheme.lightBg,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        backgroundColor: DarkTheme.lightBg,
        middle: Text(
          "Мои обменные пункты",
          style: Typography.heading2,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showAddPointForm,
          child: const Icon(
            CupertinoIcons.add_circled,
            color: DarkTheme.generalBlack,
          ),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Ошибка загрузки",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton(
                          onPressed: _getExchangePoints,
                          child: const Text("Повторить"),
                        ),
                      ],
                    ),
                  )
                : _points.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "У вас пока нет обменных пунктов",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            CupertinoButton(
                              onPressed: _showAddPointForm,
                              color: DarkTheme.generalBlack,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: const Text("Добавить"),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _points.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final point = _points[index];
                          return Dismissible(
                            key: Key(point.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: CupertinoColors.destructiveRed,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                CupertinoIcons.delete,
                                color: CupertinoColors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              _deleteExchangePoint(point.id);
                            },
                            confirmDismiss: (direction) async {
                              return await showCupertinoDialog<bool>(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Удалить обменный пункт?'),
                                      content: const Text('Вы уверены, что хотите удалить этот обменный пункт?'),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text('Отмена'),
                                          onPressed: () => Navigator.of(context).pop(false),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          child: const Text('Удалить'),
                                          onPressed: () => Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: DarkTheme.generalWhite,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoColors.systemGrey5.withOpacity(0.5),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () => _editExchangePoint(point),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Exchange point name and info
                                      Text(
                                        point.name,
                                        style: Typography.body2.merge(
                                          const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        point.info ?? '',
                                        style: Typography.body3,
                                      ),
                                      const SizedBox(height: 12),

                                      // Currency rates in vertical column
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.systemBackground,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: CupertinoColors.systemGrey6.withOpacity(0.5),
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            // Header row
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      'Валюта',
                                                      style: Typography.body3.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: DarkTheme.darkSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      'Покупка / Продажа',
                                                      style: Typography.body3.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: DarkTheme.darkSecondary,
                                                      ),
                                                      textAlign: TextAlign.right,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Divider
                                            Container(
                                              height: 0.5,
                                              width: double.infinity,
                                              color: CupertinoColors.systemGrey5.withOpacity(0.5),
                                            ),

                                            // Currency rows
                                            _buildCurrencyRow('USD', point.buyUSD, point.sellUSD),
                                            _buildCurrencyDivider(),
                                            _buildCurrencyRow('EUR', point.buyEUR, point.sellEUR),
                                            _buildCurrencyDivider(),
                                            _buildCurrencyRow('RUB', point.buyRUB, point.sellRUB),
                                            _buildCurrencyDivider(),
                                            _buildCurrencyRow('CNY', point.buyCNY, point.sellCNY),
                                            _buildCurrencyDivider(),
                                            _buildCurrencyRow('GBP', point.buyGBP, point.sellGBP),

                                            // Update time
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  'Обновлено: ${_formatDateTime(point.date_update)}',
                                                  style: Typography.body3.copyWith(
                                                    color: DarkTheme.darkSecondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildCurrencyRow(String currency, num buy, num sell) {
    final bool hasRates = buy != 0 || sell != 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Currency code
          Expanded(
            flex: 2,
            child: Text(
              currency,
              style: Typography.body3.copyWith(
                fontWeight: FontWeight.w500,
                color: DarkTheme.generalBlack,
              ),
            ),
          ),
          // Rate values
          Expanded(
            flex: 3,
            child: hasRates
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        buy == 0 ? '-' : '$buy',
                        style: Typography.body3.copyWith(
                          color: AppColors.generalGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' / ',
                        style: Typography.body3.copyWith(
                          color: DarkTheme.darkSecondary,
                        ),
                      ),
                      Text(
                        sell == 0 ? '-' : '$sell',
                        style: Typography.body3.copyWith(
                          color: AppColors.generalRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Не указано',
                    style: Typography.body3.copyWith(
                      color: DarkTheme.darkSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDivider() {
    return Container(
      height: 0.5,
      width: double.infinity,
      color: CupertinoColors.systemGrey5.withOpacity(0.5),
    );
  }

  String _formatDateTime(num timestamp) {
    if (timestamp == 0) {
      return 'Неизвестно';
    }

    // Convert seconds to milliseconds if needed
    final milliseconds = timestamp < 10000000000 ? timestamp * 1000 : timestamp;

    final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds.toInt());
    return '${_padZero(dateTime.day)}.${_padZero(dateTime.month)}.${dateTime.year} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
