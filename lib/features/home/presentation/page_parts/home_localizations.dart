class SettingsLocalization {
  static Map<String, Map<String, String>> translations = {
    'uz': {
      'personalInfo': 'Shaxsiy Ma\'lumotlar',
      'language': 'Til',
      'uzbek': 'O\'zbekcha',
      'russian': 'Русский',
      'security': 'Xavfsizlik',
      'changePassword': 'Parolni O\'zgartirish',
      'help': 'Yordam',
      'faq': 'Ko\'p So\'raladigan Savollar',
      'helpCenter': 'Yordam Markazi',
      'account': 'Akkount',
      'logout': 'Chiqish',
      'deleteAccount': 'Akkauntni O\'chirish',
      'logoutTitle': 'Chiqish',
      'logoutMessage': 'Haqiqatan ham chiqmoqchimisiz?',
      'cancel': 'Bekor qilish',
      'deleteAccountTitle': 'Akkauntni O\'chirish',
      'deleteAccountMessage':
      'Haqiqatan ham akkauntingizni o\'chirmoqchimisiz? Bu amalni ortga qaytarib bo\'lmaydi va barcha ma\'lumotlaringiz o\'chiriladi.',
      'delete': 'O\'chirish',
      'faqTitle': 'Ko\'p So\'raladigan Savollar',
      'faq1Q': 'Ilovadan qanday foydalanish kerak?',
      'faq1A': 'Ilovada asosiy funksiyalar intuitiv tarzda joylashtirilgan...',
      'faq2Q': 'Parolimni unutdim, nima qilishim kerak?',
      'faq2A': 'Kirish sahifasida "Parolni unutdingizmi?" tugmasini bosing...',
      'faq3Q': 'Qanday qilib yordam olishim mumkin?',
      'faq3A': 'Yordam Markazi orqali murojaat qilishingiz mumkin...',
      'helpCenterTitle': 'Yordam Markazi',
      'helpCenterSubtitle': 'Sizga qanday yordam bera olamiz?',
      'email': 'Email',
      'phone': 'Telefon',
      'chat': 'Chat',
      'chatOnline': 'Onlayn chat bilan bog\'laning',
      'confirmPassword': 'Parolni tasdiqlang',
      'password': 'Parol',
      'passwordRequired': 'Parol kiritilishi shart',
      'wrongPassword': 'Noto\'g\'ri parol',
      'networkError': 'Tarmoq xatosi',
      'error': 'Xato',
      'ok': 'OK',
      'confirm': 'Tasdiqlash',
    },
    'ru': {
      'personalInfo': 'Личные данные',
      'language': 'Язык',
      'uzbek': 'O\'zbekcha',
      'russian': 'Русский',
      'security': 'Безопасность',
      'changePassword': 'Изменить пароль',
      'help': 'Помощь',
      'faq': 'Часто задаваемые вопросы',
      'helpCenter': 'Центр помощи',
      'account': 'Аккаунт',
      'logout': 'Выйти',
      'deleteAccount': 'Удалить аккаунт',
      'logoutTitle': 'Выход',
      'logoutMessage': 'Вы действительно хотите выйти?',
      'cancel': 'Отмена',
      'deleteAccountTitle': 'Удаление аккаунта',
      'deleteAccountMessage':
      'Вы действительно хотите удалить свой аккаунт? Это действие нельзя отменить, и все ваши данные будут удалены.',
      'delete': 'Удалить',
      'faqTitle': 'Часто задаваемые вопросы',
      'faq1Q': 'Как пользоваться приложением?',
      'faq1A': 'Основные функции приложения расположены интуитивно...',
      'faq2Q': 'Я забыл пароль, что делать?',
      'faq2A': 'На странице входа нажмите кнопку "Забыли пароль?"...',
      'faq3Q': 'Как я могу получить помощь?',
      'faq3A': 'Вы можете обратиться через Центр помощи...',
      'helpCenterTitle': 'Центр помощи',
      'helpCenterSubtitle': 'Как мы можем вам помочь?',
      'email': 'Email',
      'phone': 'Телефон',
      'chat': 'Чат',
      'chatOnline': 'Свяжитесь через онлайн чат',
      'confirmPassword': 'Подтвердите пароль',
      'password': 'Пароль',
      'passwordRequired': 'Пароль обязателен',
      'wrongPassword': 'Неверный пароль',
      'networkError': 'Ошибка сети',
      'error': 'Ошибка',
      'ok': 'OK',
      'confirm': 'Подтвердить',
    },
  };

  static String get(String key, String locale) {
    return translations[locale]?[key] ?? translations['uz']![key]!;
  }
}

class HomeHeaderLocalizations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      'appTitle': 'Matematika Markazi',
      'appSubtitle': 'Bugun raqamlar olami bilan tanishamiz! 🚀',
      'points': 'Ball',
      'coins': 'Tanga',
      'balance': 'So\'m',
      'streak': 'kunlik ketma-ketlik!',
    },
    'ru': {
      'appTitle': 'Центр Математики',
      'appSubtitle': 'Сегодня познакомимся с миром чисел! 🚀',
      'points': 'Балл',
      'coins': 'Монета',
      'balance': 'Сум',
      'streak': 'дневная серия!',
    },
  };

  static String translate(String key, String? locale) {
    final currentLocale = locale ?? 'uz';
    return _translations[currentLocale]?[key] ?? _translations['uz']![key]!;
  }

  // Qulaylik uchun qisqa metod
  static String t(String key, String? locale) => translate(key, locale);
}

class TarifTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      'tarifPlan': 'Tarif rejasi',
      'paid': 'To\'langan',
      'som': 'So\'m',
      'nextPaymentDate': 'Keyingi to\'lov sanasi',
      'daysRemaining': 'To\'lov kuniga {days} kun qoldi',
      'currentPlan': 'Joriy reja',
      'payment': 'To\'lov',
      'discount': 'Chegirma',
      'errorLoadingData': 'Ma\'lumotlarni yuklashda xatolik yuz berdi',
      'internetError': 'Internet bilan bog\'lanishda muammo',
      'retryButton': 'Qayta urinish',
      'noPlansAvailable':'Tarif rejalar topilmadi',
      'selectPlan':'Tanlash',
    },
    'ru': {
      'tarifPlan': 'Тарифный план',
      'paid': 'Оплачено',
      'som': 'Сум',
      'nextPaymentDate': 'Следующая дата оплаты',
      'daysRemaining': 'Осталось {days} дней до оплаты',
      'currentPlan': 'Текущий план',
      'payment': 'Оплата',
      'discount': 'Скидка',
      'errorLoadingData': 'Ошибка при загрузке данных',
      'internetError': 'Проблема с подключением к интернету',
      'retryButton': 'Повторить попытку',
      'selectPlan':'Выбрать',
      'noPlansAvailable':'Планы не найдены',
    },
  };

  static String translate(String key, String? locale, {Map<String, dynamic>? params}) {
    final currentLocale = locale ?? 'uz';
    String text = _translations[currentLocale]?[key] ?? _translations['uz']![key]!;

    // Replace parameters like {days} with actual values
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value.toString());
      });
    }

    return text;
  }

  // Qulaylik uchun qisqa metod
  static String t(String key, String? locale, {Map<String, dynamic>? params}) =>
      translate(key, locale, params: params);
}

class TodaysFocusTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      'todaysGoal': 'Bugungi maqsad',
      'completed': 'Tugallandi',
      'score': 'Ball',
      'startAndLearn': 'Boshlang va o\'rganing!',
      'justNow': 'Hozirgina',
      'minutesAgo': '{minutes} daqiqa oldin',
      'hoursAgo': '{hours} soat oldin',
      'daysAgo': '{days} kun oldin',
    },
    'ru': {
      'todaysGoal': 'Сегодняшняя цель',
      'completed': 'Завершено',
      'score': 'Балл',
      'startAndLearn': 'Начните и учитесь!',
      'justNow': 'Только что',
      'minutesAgo': '{minutes} минут назад',
      'hoursAgo': '{hours} часов назад',
      'daysAgo': '{days} дней назад',
    },
  };

  static String translate(String key, String? locale, {Map<String, dynamic>? params}) {
    final currentLocale = locale ?? 'uz';
    String text = _translations[currentLocale]?[key] ?? _translations['uz']![key]!;

    // Replace parameters
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value.toString());
      });
    }

    return text;
  }

  // Qulaylik uchun qisqa metod
  static String t(String key, String? locale, {Map<String, dynamic>? params}) =>
      translate(key, locale, params: params);
}


class LearningPathTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      'learningPath': 'O\'quv Yo\'nalishi',
      'noDataYet': 'Hozircha fan ma\'lumotlari yo\'q',
      'errorLoadingData': 'Ma\'lumotlarni yuklashda xatolik',
      'internetError': 'Internet bilan bog\'lanishda xatolik',
      'retryButton': 'Qayta urinish',
      'showMore': 'Ko\'proq ko\'rish',
      'showLess': 'Kamroq ko\'rish',
      'chapter': 'bob',
      'topic': 'mavzu',
    },
    'ru': {
      'learningPath': 'Учебный Путь',
      'noDataYet': 'Пока нет данных о предметах',
      'errorLoadingData': 'Ошибка при загрузке данных',
      'internetError': 'Ошибка подключения к интернету',
      'retryButton': 'Повторить попытку',
      'showMore': 'Показать больше',
      'showLess': 'Показать меньше',
      'chapter': 'глава',
      'topic': 'тема',
    },
  };

  static String translate(String key, String? locale) {
    final currentLocale = locale ?? 'uz';
    return _translations[currentLocale]?[key] ?? _translations['uz']![key]!;
  }

  static String t(String key, String? locale) => translate(key, locale);
}

class RecentActivityTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      'recentActivity': 'So\'nggi Faoliyat',
      'viewAll': 'Hammasi',
      'newTopic': 'Yangi mavzu',
      'noSubject': 'Fan nomi yo\'q',
      'points': '%',
    },
    'ru': {
      'recentActivity': 'Недавняя Активность',
      'viewAll': 'Все',
      'newTopic': 'Новая тема',
      'noSubject': 'Название предмета отсутствует',
      'points': '%',
    },
  };

  static String translate(String key, String? locale) {
    final currentLocale = locale ?? 'uz';
    return _translations[currentLocale]?[key] ?? _translations['uz']![key]!;
  }

  static String t(String key, String? locale) => translate(key, locale);
}

class StudyTipsTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      'studyTips': 'O\'rganish Maslahatlari',
      'errorLoadingData': 'Ma\'lumotlarni yuklashda xatolik yuz berdi',
      'internetError': 'Internet bilan bog\'lanishda muammo',
      'noTipsYet': 'Hozircha maslahatlar yo\'q',
    },
    'ru': {
      'studyTips': 'Советы по Обучению',
      'errorLoadingData': 'Ошибка при загрузке данных',
      'internetError': 'Проблема с подключением к интернету',
      'noTipsYet': 'Пока нет советов',
    },
  };

  static String translate(String key, String? locale) {
    final currentLocale = locale ?? 'uz';
    return _translations[currentLocale]?[key] ?? _translations['uz']![key]!;
  }

  static String t(String key, String? locale) => translate(key, locale);
}

class WeeklyCalendarTranslations {
  static const Map<String, Map<String, dynamic>> _translations = {
    'uz': {
      'weeklyActivity': 'Haftalik faoliyat',
      'dataNotLoaded': 'Ma\'lumot yuklanmadi',
      'errorOccurred': 'Xatolik yuz berdi',
      'retryButton': 'Qayta urinish',
      'weekDays': ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'],
    },
    'ru': {
      'weeklyActivity': 'Недельная Активность',
      'dataNotLoaded': 'Данные не загружены',
      'errorOccurred': 'Произошла ошибка',
      'retryButton': 'Повторить попытку',
      'weekDays': ['Пон', 'Вто', 'Сре', 'Чет', 'Пят', 'Суб', 'Вос'],
    },
  };

  static String translate(String key, String? locale) {
    final currentLocale = locale ?? 'uz';
    return _translations[currentLocale]?[key] ?? _translations['uz']![key]!;
  }

  static List<String> getWeekDays(String? locale) {
    final currentLocale = locale ?? 'uz';
    return List<String>.from(_translations[currentLocale]?['weekDays'] ?? _translations['uz']!['weekDays']!);
  }

  static String t(String key, String? locale) => translate(key, locale);
}

class PaymentTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      // Tarif rejasi ekrani
      'selectPlan': 'Tarif rejasini tanlang',
      'selectPlanDescription': 'Tarif rejasini tanlang',
      'som': 'So\'m',
      'errorLoadingData': 'Ma\'lumotlarni yuklashda xatolik yuz berdi',
      'internetError': 'Internet bilan bog\'lanishda muammo',
      'retryButton': 'Qayta urinish',

      // Kupon dialog
      'coupons': 'Kuponlar',
      'enterPromoCode': 'Promokod kodini kiriting',
      'promoCode': 'Promokod',
      'checkCoupon': 'Kuponni tekshirish',
      'back': 'Ortga',
      'proceedToPayment': 'To\'lovga o\'tish',

      // Kupon ma\'lumotlari
      'couponApplied': 'Kupon qo\'llanildi!',
      'originalPrice': 'Asl narx:',
      'discountPercent': 'Chegirma foizi:',
      'discountAmount': 'Chegirma summasi:',
      'finalPrice': 'Yakuniy narx:',

      // Xabarlar
      'enterCouponCode': 'Iltimos, kupon kodini kiriting',
      'couponSuccess': 'Kupon muvaffaqiyatli qo\'llanildi!',
      'couponInvalid': 'Kupon yaroqsiz',
      'couponCheckError': 'Kupon tekshirishda xatolik',
      'paymentOpenError': 'To\'lov sahifasini ochishda xatolik',
      'paymentInitError': 'To\'lovni boshlashda xatolik yuz berdi',
      'buyPlan': 'Sotib olish',
    },
    'ru': {
      // Экран тарифных планов
      'selectPlan': 'Выберите тарифный план',
      'selectPlanDescription': 'Выберите тарифный план',
      'som': 'Сум',
      'errorLoadingData': 'Ошибка при загрузке данных',
      'internetError': 'Проблема с подключением к интернету',
      'retryButton': 'Повторить попытку',

      // Диалог купона
      'coupons': 'Купоны',
      'enterPromoCode': 'Введите промокод',
      'promoCode': 'Промокод',
      'checkCoupon': 'Проверить купон',
      'back': 'Назад',
      'proceedToPayment': 'Перейти к оплате',

      // Информация о купоне
      'couponApplied': 'Купон применён!',
      'originalPrice': 'Исходная цена:',
      'discountPercent': 'Процент скидки:',
      'discountAmount': 'Сумма скидки:',
      'finalPrice': 'Итоговая цена:',

      // Сообщения
      'enterCouponCode': 'Пожалуйста, введите код купона',
      'couponSuccess': 'Купон успешно применён!',
      'couponInvalid': 'Купон недействителен',
      'couponCheckError': 'Ошибка при проверке купона',
      'paymentOpenError': 'Ошибка при открытии страницы оплаты',
      'paymentInitError': 'Ошибка при инициализации платежа',
      'buyPlan': 'Купить',
    },
  };

  static String translate(String key, String? locale, {Map<String, dynamic>? params}) {
    final currentLocale = locale ?? 'uz';
    String text = _translations[currentLocale]?[key] ?? _translations['uz']![key]!;

    // Replace parameters like {days} with actual values
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value.toString());
      });
    }

    return text;
  }

  // Qulaylik uchun qisqa metod
  static String t(String key, String? locale, {Map<String, dynamic>? params}) =>
      translate(key, locale, params: params);
}