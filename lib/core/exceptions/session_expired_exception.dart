import 'api_exception.dart';

/// The server ended the session (the refresh token was rejected). The app has already sent
/// the user to the sign-in screen, which explains it, so screens don't show this error.
class SessionExpiredException extends ApiException {
  SessionExpiredException()
      : super(message: 'Сессия истекла. Войдите снова', statusCode: 401);

  @override
  String toString() => message;
}
