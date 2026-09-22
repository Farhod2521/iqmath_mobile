class BallCoinsLocalization {
  final String locale;

  BallCoinsLocalization(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'title': 'Konvertatsiya',
      'subtitle': 'Ball va tangalarni oson konvertatsiya qiling',
      'conversionRates': 'KONVERTATSIYA KURSLARI',
      'ball': 'Ball',
      'tanga': 'Tanga',
      'som': 'So\'m',
      'firstChoice': '1-tanlov: Qaysidan',
      'secondChoice': '2-tanlov: Qaysiga',
      'amount': 'miqdori',
      'toTanga': 'Tangaga',
      'toSom': 'So\'mga',
      'somEquivalent': 'So\'m ekvivalenti:',
      'convertButton': 'Konvertatsiya qilish',
      'successTitle': 'Muvaffaqiyatli!',
      'successMessage': 'Konvertatsiya amalga oshirildi',
      'errorEnterAmount': 'Iltimos, miqdorni kiriting',
      'errorTangaToSom': 'Tangadan So\'mga konvertatsiya qilish mumkin emas. Iltimos, Ball tanlang.',
      'errorInvalidType': 'Konvertatsiya turi notog\'ri tanlangan',
      'errorNetwork': 'Tarmoq xatosi:',
      'errorDefault': 'Xatolik yuz berdi',
      'footerNote': 'Barcha konvertatsiyalar avtomatik hisoblanadi va API orqali saqlanadi',
    },
    'ru': {
      'title': 'Конвертация',
      'subtitle': 'Легко конвертируйте баллы и монеты',
      'conversionRates': 'КУРСЫ КОНВЕРТАЦИИ',
      'ball': 'Балл',
      'tanga': 'Монета',
      'som': 'Сум',
      'firstChoice': '1-выбор: Из чего',
      'secondChoice': '2-выбор: Во что',
      'amount': 'количество',
      'toTanga': 'В монеты',
      'toSom': 'В сумы',
      'somEquivalent': 'Эквивалент в сумах:',
      'convertButton': 'Конвертировать',
      'successTitle': 'Успешно!',
      'successMessage': 'Конвертация выполнена',
      'errorEnterAmount': 'Пожалуйста, введите количество',
      'errorTangaToSom': 'Конвертация из монет в сумы невозможна. Пожалуйста, выберите Балл.',
      'errorInvalidType': 'Выбран неправильный тип конвертации',
      'errorNetwork': 'Ошибка сети:',
      'errorDefault': 'Произошла ошибка',
      'footerNote': 'Все конвертации автоматически рассчитываются и сохраняются через API',
    },
  };

  String translate(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues['uz']![key]!;
  }

  // Qulaylik uchun getter'lar
  String get title => translate('title');
  String get subtitle => translate('subtitle');
  String get conversionRates => translate('conversionRates');
  String get ball => translate('ball');
  String get tanga => translate('tanga');
  String get som => translate('som');
  String get firstChoice => translate('firstChoice');
  String get secondChoice => translate('secondChoice');
  String get amount => translate('amount');
  String get toTanga => translate('toTanga');
  String get toSom => translate('toSom');
  String get somEquivalent => translate('somEquivalent');
  String get convertButton => translate('convertButton');
  String get successTitle => translate('successTitle');
  String get successMessage => translate('successMessage');
  String get errorEnterAmount => translate('errorEnterAmount');
  String get errorTangaToSom => translate('errorTangaToSom');
  String get errorInvalidType => translate('errorInvalidType');
  String get errorNetwork => translate('errorNetwork');
  String get errorDefault => translate('errorDefault');
  String get footerNote => translate('footerNote');
}