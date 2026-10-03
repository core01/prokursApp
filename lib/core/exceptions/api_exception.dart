import 'package:dio/dio.dart';
import 'package:prokurs/core/exceptions/session_expired_exception.dart';
import 'package:prokurs/core/services/translation_service.dart';

typedef FieldError = ({String field, String constraint});

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  /// What failed validation, from the API's 400 body (`errors`).
  final List<FieldError> fieldErrors;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.fieldErrors = const [],
  });

  /// AuthInterceptor marks a request that failed because the session ended. For a validation
  /// error (400) keeps the API's message and field errors: those tell the user what to fix.
  factory ApiException.fromDio(DioException e) {
    if (e.error case final SessionExpiredException expired) return expired;
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;
    final body = statusCode == 400 && data is Map ? data : null;
    final message = body?['message'];
    final errors = body?['errors'];
    return ApiException(
      message: message is List ? message.join('\n') : message?.toString() ?? '',
      statusCode: statusCode,
      data: data,
      fieldErrors: [
        if (errors is List)
          for (final error in errors.whereType<Map>())
            (field: '${error['field']}', constraint: '${error['constraint']}'),
      ],
    );
  }

  /// The user-facing text, always in Russian: what exactly is wrong for a validation error,
  /// the likely cause for the rest. The API's own (English) wording is never shown.
  @override
  String toString() {
    final status = statusCode;
    if (status == null) {
      return 'Нет соединения с сервером. Проверьте интернет и попробуйте ещё раз';
    }
    if (status == 400) return _validationText();
    if (status == 403) return 'Доступ запрещён';
    if (status == 404) return 'Обменный пункт не найден. Обновите список';
    if (status == 429) return 'Слишком много попыток. Подождите минуту и попробуйте снова';
    if (status >= 500) return 'Сервер временно недоступен. Попробуйте позже';
    return 'Не удалось выполнить запрос';
  }

  String _validationText() {
    if (fieldErrors.isNotEmpty) {
      return fieldErrors
          .map((e) => TranslationService.describeFieldError(e.field, e.constraint))
          .toSet()
          .join('\n');
    }
    // An API without `errors`: its known messages are translated.
    final translated = message.split('\n').map(TranslationService.lookup).toList();
    if (message.isNotEmpty && !translated.contains(null)) return translated.join('\n');
    return 'Проверьте введённые данные';
  }
}
