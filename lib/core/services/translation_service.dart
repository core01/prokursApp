class TranslationService {
  static const _translations = {
    // Auth errors
    'User already exists': 'Пользователь с данным email уже зарегистрирован',
    'Invalid credentials': 'Неверный email или пароль',
    // Exchange point errors
    'each value in phone_numbers must be a valid phone number':
        'Проверьте номера телефонов: нужен формат +7 701 123 4567 или короткий номер из 4 цифр',
  };

  // Field names of the API's validation errors (`errors[].field`); a nested field like
  // work_modes.mon falls back to its first segment.
  static const _fieldLabels = {
    'name': 'Название',
    'info': 'Адрес',
    'city_id': 'Город',
    'gross': 'Тип обмена',
    'day_and_night': 'Круглосуточно',
    'phone_numbers': 'Телефоны',
    'longitude': 'Координаты',
    'latitude': 'Координаты',
    'wholesale_note': 'Условия опта',
    'work_modes': 'Режим работы',
    'description': 'Описание',
    'buyUSD': 'Покупка USD',
    'sellUSD': 'Продажа USD',
    'buyEUR': 'Покупка EUR',
    'sellEUR': 'Продажа EUR',
    'buyRUB': 'Покупка RUB',
    'sellRUB': 'Продажа RUB',
    'buyCNY': 'Покупка CNY',
    'sellCNY': 'Продажа CNY',
    'buyGBP': 'Покупка GBP',
    'sellGBP': 'Продажа GBP',
    'username': 'Email',
    'password': 'Пароль',
    'fullName': 'Имя',
  };

  // What a failed rule (`errors[].constraint`) means: "field.constraint" first, then the
  // constraint alone.
  static const _constraintTexts = {
    'phone_numbers.matches': 'нужен формат +7 701 123 4567 или 4 цифры',
    'min': 'не может быть отрицательным',
    'max': 'слишком большое значение',
    'isNumber': 'нужно число, не больше двух знаков после запятой',
    'isNotEmpty': 'не заполнено',
    'isEmail': 'неверный email',
    'matches': 'неверный формат',
  };

  /// The translation of [text], or null if there is none.
  static String? lookup(String text) => _translations[text];

  static String translate(String text) => lookup(text) ?? text;

  /// One API validation error as the user reads it: "Покупка USD: не может быть отрицательным".
  static String describeFieldError(String field, String constraint) {
    final label = _fieldLabels[field] ?? _fieldLabels[field.split('.').first];
    if (label == null) return 'Проверьте введённые данные';
    final text = _constraintTexts['$field.$constraint'] ??
        _constraintTexts[constraint] ??
        'неверное значение';
    return '$label: $text';
  }
}
