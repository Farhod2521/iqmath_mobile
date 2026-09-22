class SubjectDetailTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      'chapters': 'Boblar',
      'errorOccurred': 'Xatolik yuz berdi',
      'checkInternet': 'Internetni tekshiring',
      'pleaseRetry': 'Iltimos qaytadan urinib ko\'ring',
      'reload': 'Qayta yuklash',
    },
    'ru': {
      'chapters': 'Главы',
      'errorOccurred': 'Произошла ошибка',
      'checkInternet': 'Проверьте интернет',
      'pleaseRetry': 'Пожалуйста, попробуйте снова',
      'reload': 'Перезагрузить',
    },
  };

  static String translate(String key, String? locale) {
    final currentLocale = locale ?? 'uz';
    return _translations[currentLocale]?[key] ?? _translations['uz']![key]!;
  }

  static String t(String key, String? locale) => translate(key, locale);
}


class ChapterTopicsTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      'progress': 'Jarayon',
      'topicsLoading': 'Mavzular yuklanmoqda...',
      'checkInternet': 'Internetni tekshiring',
      'pleaseRetry': 'Iltimos qaytadan urinib ko\'ring',
      'reload': 'Qayta yuklash',
      'topicsNotFound': 'Mavzular topilmadi',
      'noTopicsYet': 'Bu bobda hali mavzular yo\'q',
      'topicLocked': 'Mavzu yopiq',
      'topicLockedMessage': 'Ushbu mavzu hali ochilmagan. Avvalgi mavzularni tugatishingiz kerak.',
      'ok': 'OK',
      'score': 'Score',
      'continue': 'Davom ettirish',
      'examples': 'Misollar',
      'watchVideo': 'Video ko\'rish',
      'close': 'Yopish',
    },
    'ru': {
      'progress': 'Прогресс',
      'topicsLoading': 'Загрузка тем...',
      'checkInternet': 'Проверьте интернет',
      'pleaseRetry': 'Пожалуйста, попробуйте снова',
      'reload': 'Перезагрузить',
      'topicsNotFound': 'Темы не найдены',
      'noTopicsYet': 'В этой главе пока нет тем',
      'topicLocked': 'Тема закрыта',
      'topicLockedMessage': 'Эта тема еще не открыта. Вам нужно завершить предыдущие темы.',
      'ok': 'ОК',
      'score': 'Результат',
      'continue': 'Продолжить',
      'examples': 'Практика',
      'watchVideo': 'Посмотреть видео',
      'close': 'Закрыть',
    },
  };

  static String translate(String key, String? locale) {
    final currentLocale = locale ?? 'uz';
    return _translations[currentLocale]?[key] ?? _translations['uz']![key]!;
  }

  static String t(String key, String? locale) => translate(key, locale);
}

class YoutubeVideoTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      'rotatePhone': 'Telefonni burish mumkin',
      'videoLoading': 'Video yuklanmoqda...',
    },
    'ru': {
      'rotatePhone': 'Можно повернуть телефон',
      'videoLoading': 'Видео загружается...',
    },
  };

  static String translate(String key, String? locale) {
    final currentLocale = locale ?? 'uz';
    return _translations[currentLocale]?[key] ?? _translations['uz']![key]!;
  }

  static String t(String key, String? locale) => translate(key, locale);
}

class QuestionPageTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'uz': {
      // App bar & Progress
      'question': 'Savol',

      // Buttons
      'back': 'Orqaga',
      'next': 'Keyingi',
      'finish': 'Tugatish',
      'retry': 'Qayta urinish',
      'retake': 'Qayta topshirish',
      'backToHome': 'Bosh sahifaga qaytish',
      'myResults': 'Mening natijalarim',
      'sendToMentor': 'Mentorga yuborish',
      'goToBot': 'Botga o\'tish',

      // Input & Hints
      'enterAnswer': 'Javobni kiriting',

      // Questions section
      'questions': 'Savollar',

      // Loading & Errors
      'loadingQuestions': 'Savollar yuklanmoqda...',
      'errorLoading': 'Savollarni yuklashda xatolik',
      'errorOccurred': 'Xatolik yuz berdi',
      'questionsNotFound': 'Savollar topilmadi',
      'unsupportedQuestionType': 'Qo\'llab-quvvatlanmaydigan savol turi',
      'type': 'Turi',
      'imageLoadError': 'Rasmni yuklashda xatolik',
      'completeTest': 'Testni to\'liq bajaring',

      // Results Dialog
      'yourScore': 'Sizning ballingiz',
      'youAnswered': 'Siz {total} savoldan {correct} tasiga to\'g\'ri javob berdingiz!',
      'yourResult': 'Sizning natijangiz',
      'correct': 'To\'g\'ri',
      'incorrect': 'Noto\'g\'ri',
      'recommendation': 'Tavsiya',

      // Telegram Bot
      'error': 'Xatolik',
      'resultsNotFound': 'Natijalar topilmadi',
      'serverError': 'Server xatoligi',
      'networkError': 'Tarmoq xatoligi',
      'unit':'Birlik',
    },
    'ru': {
      // App bar & Progress
      'question': 'Вопрос',

      // Buttons
      'back': 'Назад',
      'next': 'Далее',
      'finish': 'Завершить',
      'retry': 'Повторить попытку',
      'retake': 'Пересдать',
      'backToHome': 'Вернуться на главную',
      'myResults': 'Мои Результаты',
      'sendToMentor': 'Отправить ментору',
      'goToBot': 'Перейти к боту',

      // Input & Hints
      'enterAnswer': 'Введите ответ',

      // Questions section
      'questions': 'Вопросы',

      // Loading & Errors
      'loadingQuestions': 'Загрузка вопросов...',
      'errorLoading': 'Ошибка при загрузке вопросов',
      'errorOccurred': 'Произошла ошибка',
      'questionsNotFound': 'Вопросы не найдены',
      'unsupportedQuestionType': 'Неподдерживаемый тип вопроса',
      'type': 'Тип',
      'imageLoadError': 'Ошибка загрузки изображения',
      'completeTest': 'Завершите тест полностью',

      // Results Dialog
      'yourScore': 'Ваш балл',
      'youAnswered': 'Вы правильно ответили на {correct} из {total} вопросов!',
      'yourResult': 'Ваш результат',
      'correct': 'Правильно',
      'incorrect': 'Неправильно',
      'recommendation': 'Рекомендация',

      // Telegram Bot
      'error': 'Ошибка',
      'resultsNotFound': 'Результаты не найдены',
      'serverError': 'Ошибка сервера',
      'networkError': 'Ошибка сети',
      'unit':'Единица',
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

  static String t(String key, String? locale, {Map<String, dynamic>? params}) =>
      translate(key, locale, params: params);
}