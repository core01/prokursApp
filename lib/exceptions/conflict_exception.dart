import 'api_exception.dart';

class ConflictException extends ApiException {
  ConflictException({
    String? message,
    super.data,
  }) : super(
          message: message ?? 'Conflict',
          statusCode: 409,
        );

  @override
  String toString() => message;
}
