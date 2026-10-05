import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/exceptions/session_expired_exception.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/widgets/empty_state.dart';
import 'package:prokurs/features/exchange_points/data/services/exchange_points_service.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/add_exchange_point_page.dart';
import 'package:prokurs/features/exchange_points/presentation/widgets/my_points_navigation_bar.dart';
import 'package:prokurs/features/exchange_points/presentation/widgets/my_points_points_list.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:prokurs/features/rates/presentation/state/exchange_rates_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPointsPage extends StatefulWidget {
  static const routeName = '/my-points';

  /// A SharedPreferences flag: the cabinet was open when the app last closed, so the next
  /// launch opens it again, over the rates (Apple HIG, Launching: restore the previous state).
  static const reopenOnLaunchKey = 'myPointsOpen';

  const MyPointsPage({super.key, this.service});

  /// Where the points come from; tests pass a fake.
  final ExchangePointsService? service;

  @override
  _MyPointsState createState() => _MyPointsState();
}

class _MyPointsState extends State<MyPointsPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<ExchangePoint> _points = [];
  late final ExchangePointsService _exchangePointsService =
      widget.service ?? ExchangePointsService();

  @override
  void initState() {
    super.initState();
    _rememberOpen(true);
    _loadPoints();
  }

  @override
  void dispose() {
    // Gone back or signed out: the next launch opens the rates.
    _rememberOpen(false);
    super.dispose();
  }

  static Future<void> _rememberOpen(bool open) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(MyPointsPage.reopenOnLaunchKey, open);
  }

  /// The first load and "Повторить", with a spinner. Pull-to-refresh has its own indicator.
  Future<void> _loadPoints() async {
    if (!_isLoading) setState(() => _isLoading = true);
    await _getExchangePoints();
    if (mounted) setState(() => _isLoading = false);
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
    } on SessionExpiredException {
      // The app is on its way to the sign-in screen, which explains it.
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Ошибка загрузки обменных пунктов. Потяните экран вниз или нажмите на кнопку "Повторить"';
        });
      }
    }
  }

  /// A point was added or changed: the cabinet's list and the rates under the cabinet load
  /// it again, so going back shows the new rates and wholesale conditions.
  void _onPointsChanged() {
    _getExchangePoints();
    context.read<ExchangeRatesProvider>().refresh();
  }

  void _showAddPointForm() {
    Navigator.of(context)
        .push(
          CupertinoPageRoute(
            builder: (context) => AddExchangePointPage(
              exchangePoint: null, // null for new point
              service: _exchangePointsService,
            ),
          ),
        )
        .then((exchangePointData) {
          if (exchangePointData != null && mounted) _onPointsChanged();
        });
  }

  void _editExchangePoint(ExchangePoint point) {
    Navigator.of(context)
        .push(
          CupertinoPageRoute(
            builder: (context) => AddExchangePointPage(
                exchangePoint: point, service: _exchangePointsService)))
        .then((updatedPoint) {
      if (updatedPoint != null && mounted) _onPointsChanged();
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
        context.read<ExchangeRatesProvider>().refresh();
      }
    } on SessionExpiredException {
      // The app is on its way to the sign-in screen, which explains it.
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

    return CupertinoPageScaffold(
      navigationBar: MyPointsNavigationBar(
        userEmail: userEmail,
        onSignOut: () => authProvider.signOut(),
        onAdd: _showAddPointForm,
      ),
      child: SafeArea(
        bottom: false,
        // The content replaces the spinner with a short cross-fade, as soon as it arrives.
        child: AnimatedSwitcher(
          duration: AppMotion.duration,
          switchInCurve: AppMotion.curve,
          switchOutCurve: AppMotion.curve,
          child: _points.isEmpty
              ? _buildWithoutPoints()
              : MyPointsPointsList(
                  key: const ValueKey('list'),
                  points: _points,
                  errorMessage: _errorMessage,
                  isLoading: _isLoading,
                  onRefresh: _getExchangePoints,
                  onRetry: _loadPoints,
                  onEdit: _editExchangePoint,
                  onDelete: _deleteExchangePoint,
                  formatDateTime: _formatDateTime,
                ),
        ),
      ),
    );
  }

  Widget _buildWithoutPoints() {
    if (_isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CupertinoActivityIndicator(),
      );
    }
    return CustomScrollView(
      key: ValueKey(_errorMessage == null ? 'empty' : 'error'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _getExchangePoints),
        SliverFillRemaining(
          hasScrollBody: false,
          child: _errorMessage != null
              ? EmptyState(
                  title: 'Упс! Что-то пошло не так',
                  message: _errorMessage,
                  actionLabel: 'Повторить',
                  onAction: _loadPoints,
                )
              : EmptyState(
                  title: 'У вас пока нет обменных пунктов',
                  actionLabel: 'Добавить',
                  onAction: _showAddPointForm,
                ),
        ),
      ],
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
