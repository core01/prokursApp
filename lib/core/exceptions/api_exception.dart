class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() =>
      'Ошибка! Попробуйте позже: ${statusCode != null ? ' ($statusCode)' : ''}';
}
