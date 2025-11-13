class TranslationService {
  static String translate(String text) {
    const translations = {
      // Auth errors
      'User already exists': 'Пользователь с данным email уже зарегистрирован',
      'Invalid credentials': 'Неверный email или пароль',
    };

    return translations[text] ?? text;
  }
}
