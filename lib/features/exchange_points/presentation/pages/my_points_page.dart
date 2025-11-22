import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/features/exchange_points/data/services/exchange_points_service.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/add_exchange_point_page.dart';
import 'package:prokurs/features/exchange_points/presentation/widgets/my_points_empty_state.dart';
import 'package:prokurs/features/exchange_points/presentation/widgets/my_points_navigation_bar.dart';
import 'package:prokurs/features/exchange_points/presentation/widgets/my_points_points_list.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:provider/provider.dart';

class MyPointsPage extends StatefulWidget {
  static const routeName = '/my-points';

  const MyPointsPage({super.key});

  @override
  _MyPointsState createState() => _MyPointsState();
}

class _MyPointsState extends State<MyPointsPage> {
  bool _isLoading = true;
  bool _isInitializationNeeded = true;
  String? _errorMessage;
  List<ExchangePoint> _points = [];
  final ExchangePointsService _exchangePointsService = ExchangePointsService();

  @override
  void initState() {
    super.initState();
    _getExchangePoints();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInitializationNeeded) {
      setState(() {
        _isLoading = true;
      });
      await _getExchangePoints();
      _isInitializationNeeded = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future<void> _getExchangePoints() async {
    try {
      // Fetch user's exchange points
      final points = await _exchangePointsService.getMyExchangePointsList();
      if (mounted) {
        setState(() {
          _points = points;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Ошибка загрузки обменных пунктов. Потяните экран вниз или нажмите на кнопку "Повторить"';
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
            builder: (context) => AddExchangePointPage(exchangePoint: point)))
        .then((updatedPoint) {
      if (updatedPoint != null) {
        _getExchangePoints(); // Refresh the list from API
      }
    });
  }

  Future<void> _deleteExchangePoint(num id) async {
    try {
      // Then make the API call
      await _exchangePointsService.deleteExchangePoint(id);
      // First update the UI to remove the item
      if (mounted) {
        setState(() {
          _points.removeWhere((p) => p.id == id);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Не удалось удалить обменный пункт';
          debugPrint('Error: $e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = context.watch<AuthProvider>().userEmail;
    final authProvider = context.read<AuthProvider>();

final theme = CupertinoTheme.of(context);
    final Color themePrimaryColor = CupertinoDynamicColor.resolve(theme.primaryColor, context);
    final Color themePrimaryContrastingColor = CupertinoDynamicColor.resolve(theme.primaryContrastingColor, context);
    final Color themeScaffoldBackgroundColor = CupertinoDynamicColor.resolve(theme.scaffoldBackgroundColor, context);
    final Color themeBarBackgroundColor = CupertinoDynamicColor.resolve(theme.barBackgroundColor, context);

    return CupertinoPageScaffold(
      backgroundColor: themeScaffoldBackgroundColor,
      navigationBar: MyPointsNavigationBar(
        userEmail: userEmail,
        onSignOut: () => authProvider.signOut(),
        onAdd: _showAddPointForm,
        themePrimaryColor: themePrimaryColor,
      ),
      child: SafeArea(
        child: _points.isEmpty
            ? MyPointsEmptyState(onAdd: _showAddPointForm)
            : MyPointsPointsList(
                points: _points,
                errorMessage: _errorMessage,
                isLoading: _isLoading,
                onRefresh: _getExchangePoints,
                onRetry: _getExchangePoints,
                onEdit: _editExchangePoint,
                onDelete: _deleteExchangePoint,
                formatDateTime: _formatDateTime,
              ),
      ),
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
