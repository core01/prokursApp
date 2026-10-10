import 'package:dio/dio.dart';

/// The API takes a calendar date as `YYYY-MM-DD`, but the generated models hold it as a
/// [DateTime], which json_serializable writes as a full ISO date-time
/// (`2024-03-15T00:00:00.000`), and the API answers that with a 400.
///
/// A date in this app's requests is a day the owner picked, so it sits at midnight: a value of
/// that shape in a JSON body is cut to its date. Nothing else in the API's requests is a time.
class DateOnlyInterceptor extends Interceptor {
  const DateOnlyInterceptor();

  static final _midnight = RegExp(r'^(\d{4}-\d{2}-\d{2})T00:00:00(\.0+)?Z?$');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = options.data;
    if (data is Map<String, dynamic>) {
      options.data = {
        for (final entry in data.entries) entry.key: _dateOnly(entry.value),
      };
    }
    handler.next(options);
  }

  static Object? _dateOnly(Object? value) =>
      value is String ? _midnight.firstMatch(value)?.group(1) ?? value : value;
}
