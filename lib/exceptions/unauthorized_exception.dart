import 'api_exception.dart';

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    super.message = 'Unauthorized',
    super.data,
  }) : super(statusCode: 401);

  @override
  String toString() => message;
}
