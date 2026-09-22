// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalization {
  AppLocalization();

  static AppLocalization? _current;

  static AppLocalization get current {
    assert(
      _current != null,
      'No instance of AppLocalization was loaded. Try to initialize the AppLocalization delegate before accessing AppLocalization.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalization> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalization();
      AppLocalization._current = instance;

      return instance;
    });
  }

  static AppLocalization of(BuildContext context) {
    final instance = AppLocalization.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppLocalization present in the widget tree. Did you add AppLocalization.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalization? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  /// `Добро \nпожаловать`
  String get welcome {
    return Intl.message(
      'Добро \nпожаловать',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Зарегистрироваться`
  String get register {
    return Intl.message(
      'Зарегистрироваться',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Авторизоваться`
  String get authorization {
    return Intl.message(
      'Авторизоваться',
      name: 'authorization',
      desc: '',
      args: [],
    );
  }

  /// `Продолжить`
  String get next {
    return Intl.message('Продолжить', name: 'next', desc: '', args: []);
  }

  /// `Вход в приложение`
  String get enter_app {
    return Intl.message(
      'Вход в приложение',
      name: 'enter_app',
      desc: '',
      args: [],
    );
  }

  /// `Укажите номер вашего телефона, он \nостанется между нами`
  String get show_your_phone_number {
    return Intl.message(
      'Укажите номер вашего телефона, он \nостанется между нами',
      name: 'show_your_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Введите код из SMS`
  String get enter_sms {
    return Intl.message(
      'Введите код из SMS',
      name: 'enter_sms',
      desc: '',
      args: [],
    );
  }

  /// `Представьтесь`
  String get introduce_yourself {
    return Intl.message(
      'Представьтесь',
      name: 'introduce_yourself',
      desc: '',
      args: [],
    );
  }

  /// `Как нам к вам обращаться,\nпожалуйста укажите правильные данные,\nчтобы не было неудобно.`
  String get how_to_call_you {
    return Intl.message(
      'Как нам к вам обращаться,\nпожалуйста укажите правильные данные,\nчтобы не было неудобно.',
      name: 'how_to_call_you',
      desc: '',
      args: [],
    );
  }

  /// `Я соглашаюсь на обработку персональных данных в соответствии с Офертой и Политикой обработки персональных данных`
  String get offerta1 {
    return Intl.message(
      'Я соглашаюсь на обработку персональных данных в соответствии с Офертой и Политикой обработки персональных данных',
      name: 'offerta1',
      desc: '',
      args: [],
    );
  }

  /// `Я хочу получать предложения об акциях и скидках`
  String get offerta2 {
    return Intl.message(
      'Я хочу получать предложения об акциях и скидках',
      name: 'offerta2',
      desc: '',
      args: [],
    );
  }

  /// `Не было смс / звонка?`
  String get no_sms {
    return Intl.message(
      'Не было смс / звонка?',
      name: 'no_sms',
      desc: '',
      args: [],
    );
  }

  /// `Запросить повторно через `
  String get resend_sms {
    return Intl.message(
      'Запросить повторно через ',
      name: 'resend_sms',
      desc: '',
      args: [],
    );
  }

  /// `Ваше имя`
  String get your_name {
    return Intl.message('Ваше имя', name: 'your_name', desc: '', args: []);
  }

  /// `Фамилия`
  String get surname {
    return Intl.message('Фамилия', name: 'surname', desc: '', args: []);
  }

  /// `Создайте PIN код`
  String get create_pin {
    return Intl.message(
      'Создайте PIN код',
      name: 'create_pin',
      desc: '',
      args: [],
    );
  }

  /// `Для защиты входа в приложение`
  String get for_security {
    return Intl.message(
      'Для защиты входа в приложение',
      name: 'for_security',
      desc: '',
      args: [],
    );
  }

  /// `Включить Биометрику`
  String get turn_on_biometric {
    return Intl.message(
      'Включить Биометрику',
      name: 'turn_on_biometric',
      desc: '',
      args: [],
    );
  }

  /// `Иван`
  String get example_name {
    return Intl.message('Иван', name: 'example_name', desc: '', args: []);
  }

  /// `Иванов`
  String get example_surname {
    return Intl.message('Иванов', name: 'example_surname', desc: '', args: []);
  }

  /// `Введите PIN код`
  String get enter_pin {
    return Intl.message(
      'Введите PIN код',
      name: 'enter_pin',
      desc: '',
      args: [],
    );
  }

  /// `Забыли PIN код?`
  String get forgot_pin {
    return Intl.message(
      'Забыли PIN код?',
      name: 'forgot_pin',
      desc: '',
      args: [],
    );
  }

  /// `Подтвердите PIN код`
  String get confirm_pin {
    return Intl.message(
      'Подтвердите PIN код',
      name: 'confirm_pin',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, заполните все поля`
  String get please_fill {
    return Intl.message(
      'Пожалуйста, заполните все поля',
      name: 'please_fill',
      desc: '',
      args: [],
    );
  }

  /// `Лента`
  String get home {
    return Intl.message('Лента', name: 'home', desc: '', args: []);
  }

  /// `Поиск`
  String get search {
    return Intl.message('Поиск', name: 'search', desc: '', args: []);
  }

  /// `Оплата`
  String get pay {
    return Intl.message('Оплата', name: 'pay', desc: '', args: []);
  }

  /// `Кошелек`
  String get wallet {
    return Intl.message('Кошелек', name: 'wallet', desc: '', args: []);
  }

  /// `Профиль`
  String get profile {
    return Intl.message('Профиль', name: 'profile', desc: '', args: []);
  }

  /// `Доброе утро`
  String get good_morning {
    return Intl.message(
      'Доброе утро',
      name: 'good_morning',
      desc: '',
      args: [],
    );
  }

  /// `Забронировать`
  String get book {
    return Intl.message('Забронировать', name: 'book', desc: '', args: []);
  }

  /// `Доставка`
  String get delivery {
    return Intl.message('Доставка', name: 'delivery', desc: '', args: []);
  }

  /// `Избранные`
  String get favorites {
    return Intl.message('Избранные', name: 'favorites', desc: '', args: []);
  }

  /// `Популярные рестораны`
  String get popular_restaurants {
    return Intl.message(
      'Популярные рестораны',
      name: 'popular_restaurants',
      desc: '',
      args: [],
    );
  }

  /// `Рекомендуем`
  String get suggestions {
    return Intl.message('Рекомендуем', name: 'suggestions', desc: '', args: []);
  }

  /// `На карте`
  String get on_map {
    return Intl.message('На карте', name: 'on_map', desc: '', args: []);
  }

  /// `Оформить доставку`
  String get order_now {
    return Intl.message(
      'Оформить доставку',
      name: 'order_now',
      desc: '',
      args: [],
    );
  }

  /// `Забронировать стол`
  String get book_table {
    return Intl.message(
      'Забронировать стол',
      name: 'book_table',
      desc: '',
      args: [],
    );
  }

  /// `Меню`
  String get menu {
    return Intl.message('Меню', name: 'menu', desc: '', args: []);
  }

  /// `Посмотреть меню`
  String get see_menu {
    return Intl.message(
      'Посмотреть меню',
      name: 'see_menu',
      desc: '',
      args: [],
    );
  }

  /// `Ваш кошелек`
  String get your_pocket {
    return Intl.message('Ваш кошелек', name: 'your_pocket', desc: '', args: []);
  }

  /// `О ресторане`
  String get about_restaurant {
    return Intl.message(
      'О ресторане',
      name: 'about_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `Мы в социальных сетях`
  String get we_social_medias {
    return Intl.message(
      'Мы в социальных сетях',
      name: 'we_social_medias',
      desc: '',
      args: [],
    );
  }

  /// `Фотографии`
  String get photos {
    return Intl.message('Фотографии', name: 'photos', desc: '', args: []);
  }

  /// `Скоро`
  String get soon {
    return Intl.message('Скоро', name: 'soon', desc: '', args: []);
  }

  /// `Данный раздел находится \nв разработке.`
  String get given_section_developing {
    return Intl.message(
      'Данный раздел находится \nв разработке.',
      name: 'given_section_developing',
      desc: '',
      args: [],
    );
  }

  /// `Вернуться назад`
  String get get_back {
    return Intl.message(
      'Вернуться назад',
      name: 'get_back',
      desc: '',
      args: [],
    );
  }

  /// `Поиск ресторанов и еды`
  String get search_restaurants_and_dishes {
    return Intl.message(
      'Поиск ресторанов и еды',
      name: 'search_restaurants_and_dishes',
      desc: '',
      args: [],
    );
  }

  /// `Поиск ресторана`
  String get search_restaurant {
    return Intl.message(
      'Поиск ресторана',
      name: 'search_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `Текущий статус`
  String get current_status {
    return Intl.message(
      'Текущий статус',
      name: 'current_status',
      desc: '',
      args: [],
    );
  }

  /// `Бонусная программа`
  String get bonus_program {
    return Intl.message(
      'Бонусная программа',
      name: 'bonus_program',
      desc: '',
      args: [],
    );
  }

  /// `Как повысить статус?`
  String get how_to_increase_status {
    return Intl.message(
      'Как повысить статус?',
      name: 'how_to_increase_status',
      desc: '',
      args: [],
    );
  }

  /// `До следующего статуса`
  String get until_next_status {
    return Intl.message(
      'До следующего статуса',
      name: 'until_next_status',
      desc: '',
      args: [],
    );
  }

  /// `Возвращается баллами с оплаты`
  String get return_with_scores {
    return Intl.message(
      'Возвращается баллами с оплаты',
      name: 'return_with_scores',
      desc: '',
      args: [],
    );
  }

  /// `Баллами можно оплатить определенный \nпроцент счета`
  String get with_scores_pay {
    return Intl.message(
      'Баллами можно оплатить определенный \nпроцент счета',
      name: 'with_scores_pay',
      desc: '',
      args: [],
    );
  }

  /// `Base`
  String get base {
    return Intl.message('Base', name: 'base', desc: '', args: []);
  }

  /// `Silver`
  String get silver {
    return Intl.message('Silver', name: 'silver', desc: '', args: []);
  }

  /// `Gold`
  String get gold {
    return Intl.message('Gold', name: 'gold', desc: '', args: []);
  }

  /// `Кэшбэк`
  String get cashback {
    return Intl.message('Кэшбэк', name: 'cashback', desc: '', args: []);
  }

  /// `Осталось до следующего уровня`
  String get until_next_level {
    return Intl.message(
      'Осталось до следующего уровня',
      name: 'until_next_level',
      desc: '',
      args: [],
    );
  }

  /// `Списание баллами`
  String get withdraw_with_scores {
    return Intl.message(
      'Списание баллами',
      name: 'withdraw_with_scores',
      desc: '',
      args: [],
    );
  }

  /// `cум`
  String get sum {
    return Intl.message('cум', name: 'sum', desc: '', args: []);
  }

  /// `Фильтр`
  String get filter {
    return Intl.message('Фильтр', name: 'filter', desc: '', args: []);
  }

  /// `Применить`
  String get apply {
    return Intl.message('Применить', name: 'apply', desc: '', args: []);
  }

  /// `Сбросить`
  String get clear {
    return Intl.message('Сбросить', name: 'clear', desc: '', args: []);
  }

  /// `Ваш уровень`
  String get your_level {
    return Intl.message('Ваш уровень', name: 'your_level', desc: '', args: []);
  }

  /// `Оцените качество обслуги`
  String get rate_quality_service {
    return Intl.message(
      'Оцените качество обслуги',
      name: 'rate_quality_service',
      desc: '',
      args: [],
    );
  }

  /// `Если есть пожелания, можете \nнаписать тут...`
  String get if_you_wish {
    return Intl.message(
      'Если есть пожелания, можете \nнаписать тут...',
      name: 'if_you_wish',
      desc: '',
      args: [],
    );
  }

  /// `Отправить`
  String get send {
    return Intl.message('Отправить', name: 'send', desc: '', args: []);
  }

  /// `Пропустить`
  String get skip {
    return Intl.message('Пропустить', name: 'skip', desc: '', args: []);
  }

  /// `Мои заказы`
  String get my_orders {
    return Intl.message('Мои заказы', name: 'my_orders', desc: '', args: []);
  }

  /// `Мои бронирования`
  String get my_books {
    return Intl.message(
      'Мои бронирования',
      name: 'my_books',
      desc: '',
      args: [],
    );
  }

  /// `Банковская карта`
  String get bank_card {
    return Intl.message(
      'Банковская карта',
      name: 'bank_card',
      desc: '',
      args: [],
    );
  }

  /// `Избранные рестораны`
  String get favorite_restaurants {
    return Intl.message(
      'Избранные рестораны',
      name: 'favorite_restaurants',
      desc: '',
      args: [],
    );
  }

  /// `Чат с поддержкой`
  String get chat_with_support {
    return Intl.message(
      'Чат с поддержкой',
      name: 'chat_with_support',
      desc: '',
      args: [],
    );
  }

  /// `Вопросы и ответы`
  String get questions_and_answers {
    return Intl.message(
      'Вопросы и ответы',
      name: 'questions_and_answers',
      desc: '',
      args: [],
    );
  }

  /// `Выйти`
  String get exit {
    return Intl.message('Выйти', name: 'exit', desc: '', args: []);
  }

  /// `Редактирование`
  String get edit {
    return Intl.message('Редактирование', name: 'edit', desc: '', args: []);
  }

  /// `Изменить фото`
  String get change_photo {
    return Intl.message(
      'Изменить фото',
      name: 'change_photo',
      desc: '',
      args: [],
    );
  }

  /// `Введите ваше имя`
  String get enter_your_name {
    return Intl.message(
      'Введите ваше имя',
      name: 'enter_your_name',
      desc: '',
      args: [],
    );
  }

  /// `Введите вашу фамилию`
  String get enter_your_surname {
    return Intl.message(
      'Введите вашу фамилию',
      name: 'enter_your_surname',
      desc: '',
      args: [],
    );
  }

  /// `Дата рождения`
  String get date_of_birth {
    return Intl.message(
      'Дата рождения',
      name: 'date_of_birth',
      desc: '',
      args: [],
    );
  }

  /// `Номер телефона`
  String get phone_number {
    return Intl.message(
      'Номер телефона',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить изменения`
  String get save_changes {
    return Intl.message(
      'Сохранить изменения',
      name: 'save_changes',
      desc: '',
      args: [],
    );
  }

  /// `Из галереи`
  String get from_gallery {
    return Intl.message('Из галереи', name: 'from_gallery', desc: '', args: []);
  }

  /// `Сделать фото`
  String get from_camera {
    return Intl.message(
      'Сделать фото',
      name: 'from_camera',
      desc: '',
      args: [],
    );
  }

  /// `Отмена`
  String get cancel {
    return Intl.message('Отмена', name: 'cancel', desc: '', args: []);
  }

  /// `g`
  String get gram {
    return Intl.message('g', name: 'gram', desc: '', args: []);
  }

  /// `Работает до`
  String get work_until {
    return Intl.message('Работает до', name: 'work_until', desc: '', args: []);
  }

  /// `Рестораны`
  String get restaurants {
    return Intl.message('Рестораны', name: 'restaurants', desc: '', args: []);
  }

  /// `Уведомления`
  String get notification {
    return Intl.message(
      'Уведомления',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Тут пока пусто`
  String get here_yet_empty {
    return Intl.message(
      'Тут пока пусто',
      name: 'here_yet_empty',
      desc: '',
      args: [],
    );
  }

  /// `Возвращайтесь позже`
  String get comback_later {
    return Intl.message(
      'Возвращайтесь позже',
      name: 'comback_later',
      desc: '',
      args: [],
    );
  }

  /// `порция`
  String get portion {
    return Intl.message('порция', name: 'portion', desc: '', args: []);
  }

  /// `Изменить язык`
  String get change_language {
    return Intl.message(
      'Изменить язык',
      name: 'change_language',
      desc: '',
      args: [],
    );
  }

  /// `Безопасность`
  String get security {
    return Intl.message('Безопасность', name: 'security', desc: '', args: []);
  }

  /// `Вопросы и ответы (F.A.Q.)`
  String get questions_answers {
    return Intl.message(
      'Вопросы и ответы (F.A.Q.)',
      name: 'questions_answers',
      desc: '',
      args: [],
    );
  }

  /// `Выберите карты`
  String get choose_maps {
    return Intl.message(
      'Выберите карты',
      name: 'choose_maps',
      desc: '',
      args: [],
    );
  }

  /// `Позвонить в ресторан`
  String get call_restaurant {
    return Intl.message(
      'Позвонить в ресторан',
      name: 'call_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `Вы действительно \nхотите выйти?`
  String get want_exit {
    return Intl.message(
      'Вы действительно \nхотите выйти?',
      name: 'want_exit',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `km`
  String get km {
    return Intl.message('km', name: 'km', desc: '', args: []);
  }

  /// `Изменить PIN код`
  String get change_pin_code {
    return Intl.message(
      'Изменить PIN код',
      name: 'change_pin_code',
      desc: '',
      args: [],
    );
  }

  /// `PIN код для авторизации в приложении`
  String get pin_code_for_authorization {
    return Intl.message(
      'PIN код для авторизации в приложении',
      name: 'pin_code_for_authorization',
      desc: '',
      args: [],
    );
  }

  /// `Face ID или Touch ID`
  String get face_id_or_touch_id {
    return Intl.message(
      'Face ID или Touch ID',
      name: 'face_id_or_touch_id',
      desc: '',
      args: [],
    );
  }

  /// `Для автоматического входа`
  String get for_automatic_enter {
    return Intl.message(
      'Для автоматического входа',
      name: 'for_automatic_enter',
      desc: '',
      args: [],
    );
  }

  /// `Введите старый \nPIN код`
  String get enter_old_pin_code {
    return Intl.message(
      'Введите старый \nPIN код',
      name: 'enter_old_pin_code',
      desc: '',
      args: [],
    );
  }

  /// `Введите новый \nPIN код`
  String get enter_new_pin_code {
    return Intl.message(
      'Введите новый \nPIN код',
      name: 'enter_new_pin_code',
      desc: '',
      args: [],
    );
  }

  /// `Добрый день`
  String get good_afternoon {
    return Intl.message(
      'Добрый день',
      name: 'good_afternoon',
      desc: '',
      args: [],
    );
  }

  /// `Добрый вечер`
  String get good_evening {
    return Intl.message(
      'Добрый вечер',
      name: 'good_evening',
      desc: '',
      args: [],
    );
  }

  /// `Доброй ночи`
  String get good_night {
    return Intl.message('Доброй ночи', name: 'good_night', desc: '', args: []);
  }

  /// `Код подтверждения`
  String get confirmation_code {
    return Intl.message(
      'Код подтверждения',
      name: 'confirmation_code',
      desc: '',
      args: [],
    );
  }

  /// `Отправить код заново`
  String get resend_code {
    return Intl.message(
      'Отправить код заново',
      name: 'resend_code',
      desc: '',
      args: [],
    );
  }

  /// `Мы отправили проверочный код на номер`
  String get we_send_code {
    return Intl.message(
      'Мы отправили проверочный код на номер',
      name: 'we_send_code',
      desc: '',
      args: [],
    );
  }

  /// `Гость`
  String get guest {
    return Intl.message('Гость', name: 'guest', desc: '', args: []);
  }

  /// `Войти / Зарегистрироваться`
  String get login_or_register {
    return Intl.message(
      'Войти / Зарегистрироваться',
      name: 'login_or_register',
      desc: '',
      args: [],
    );
  }

  /// `Тут пусто`
  String get here_empty {
    return Intl.message('Тут пусто', name: 'here_empty', desc: '', args: []);
  }

  /// `Войдите или зарегистрируйтесь чтобы добавить в избранное`
  String get login_or_register_to_like {
    return Intl.message(
      'Войдите или зарегистрируйтесь чтобы добавить в избранное',
      name: 'login_or_register_to_like',
      desc: '',
      args: [],
    );
  }

  /// `Войдите или зарегистрируйтесь чтобы открыть кошелек`
  String get login_or_register_continue {
    return Intl.message(
      'Войдите или зарегистрируйтесь чтобы открыть кошелек',
      name: 'login_or_register_continue',
      desc: '',
      args: [],
    );
  }

  /// `Войдите или зарегистрируйтесь чтобы сканировать QR код`
  String get login_or_register_to_scan {
    return Intl.message(
      'Войдите или зарегистрируйтесь чтобы сканировать QR код',
      name: 'login_or_register_to_scan',
      desc: '',
      args: [],
    );
  }

  /// `Чтобы открыть кошелек, пожалуйста посетите любимый ресторан`
  String get in_order_to_continue_attend {
    return Intl.message(
      'Чтобы открыть кошелек, пожалуйста посетите любимый ресторан',
      name: 'in_order_to_continue_attend',
      desc: '',
      args: [],
    );
  }

  /// `ничего не найдено`
  String get nothing_found {
    return Intl.message(
      'ничего не найдено',
      name: 'nothing_found',
      desc: '',
      args: [],
    );
  }

  /// `Поиск еды`
  String get search_dishes {
    return Intl.message('Поиск еды', name: 'search_dishes', desc: '', args: []);
  }

  /// `блюд`
  String get dishes {
    return Intl.message('блюд', name: 'dishes', desc: '', args: []);
  }

  /// `Данный ресторан еще не наш партнер`
  String get not_partner_yet {
    return Intl.message(
      'Данный ресторан еще не наш партнер',
      name: 'not_partner_yet',
      desc: '',
      args: [],
    );
  }

  /// `Если вы хотите увидеть данный ресторан в нашем приложении нажмите на кнопку “Хочу”`
  String get if_you_want_partner {
    return Intl.message(
      'Если вы хотите увидеть данный ресторан в нашем приложении нажмите на кнопку “Хочу”',
      name: 'if_you_want_partner',
      desc: '',
      args: [],
    );
  }

  /// `Хочу`
  String get want {
    return Intl.message('Хочу', name: 'want', desc: '', args: []);
  }

  /// `Ср. чек от`
  String get medium_check {
    return Intl.message('Ср. чек от', name: 'medium_check', desc: '', args: []);
  }

  /// `Выберите любимый ресторан, и он появится в избранных.`
  String get empty_favorites_page_text {
    return Intl.message(
      'Выберите любимый ресторан, и он появится в избранных.',
      name: 'empty_favorites_page_text',
      desc: '',
      args: [],
    );
  }

  /// `Войдите или зарегистрируйтесь чтобы добаваить избранные рестораны.`
  String get guest_favorites_page_text {
    return Intl.message(
      'Войдите или зарегистрируйтесь чтобы добаваить избранные рестораны.',
      name: 'guest_favorites_page_text',
      desc: '',
      args: [],
    );
  }

  /// `Bill`
  String get check {
    return Intl.message('Bill', name: 'check', desc: '', args: []);
  }

  /// `Your balance`
  String get your_balance {
    return Intl.message(
      'Your balance',
      name: 'your_balance',
      desc: '',
      args: [],
    );
  }

  /// `Your bill`
  String get your_check {
    return Intl.message('Your bill', name: 'your_check', desc: '', args: []);
  }

  /// `Rate the quality of service`
  String get assess_the_quality_of_service {
    return Intl.message(
      'Rate the quality of service',
      name: 'assess_the_quality_of_service',
      desc: '',
      args: [],
    );
  }

  /// `Pay`
  String get to_pay {
    return Intl.message('Pay', name: 'to_pay', desc: '', args: []);
  }

  /// `Save up`
  String get accumulate {
    return Intl.message('Save up', name: 'accumulate', desc: '', args: []);
  }

  /// `Total cashback`
  String get total_cashback {
    return Intl.message(
      'Total cashback',
      name: 'total_cashback',
      desc: '',
      args: [],
    );
  }

  /// `Your cashback`
  String get sum_cashback {
    return Intl.message(
      'Your cashback',
      name: 'sum_cashback',
      desc: '',
      args: [],
    );
  }

  /// `Succes`
  String get success {
    return Intl.message('Succes', name: 'success', desc: '', args: []);
  }

  /// `Your check has been successfully registered`
  String get your_check_successfully_registered {
    return Intl.message(
      'Your check has been successfully registered',
      name: 'your_check_successfully_registered',
      desc: '',
      args: [],
    );
  }

  /// `Delete your account`
  String get delete_account {
    return Intl.message(
      'Delete your account',
      name: 'delete_account',
      desc: '',
      args: [],
    );
  }

  /// `After deleting your account, all data associated with the account will be lost.`
  String get delete_account_text {
    return Intl.message(
      'After deleting your account, all data associated with the account will be lost.',
      name: 'delete_account_text',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Application version`
  String get app_version {
    return Intl.message(
      'Application version',
      name: 'app_version',
      desc: '',
      args: [],
    );
  }

  /// `New update available`
  String get new_version {
    return Intl.message(
      'New update available',
      name: 'new_version',
      desc: '',
      args: [],
    );
  }

  /// `Please update the application before use.`
  String get new_version_description {
    return Intl.message(
      'Please update the application before use.',
      name: 'new_version_description',
      desc: '',
      args: [],
    );
  }

  /// `Update application`
  String get update_app {
    return Intl.message(
      'Update application',
      name: 'update_app',
      desc: '',
      args: [],
    );
  }

  /// `Мы ищем ваш заказ...`
  String get search_order {
    return Intl.message(
      'Мы ищем ваш заказ...',
      name: 'search_order',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, подождите. \nНам нужно немного времени...`
  String get please_wait {
    return Intl.message(
      'Пожалуйста, подождите. \nНам нужно немного времени...',
      name: 'please_wait',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, \nне закрывайте страницу`
  String get please_not_close {
    return Intl.message(
      'Пожалуйста, \nне закрывайте страницу',
      name: 'please_not_close',
      desc: '',
      args: [],
    );
  }

  /// `Покажите данную страницу официанту,\nдля корректировки суммы оплаты`
  String get show_to_waiter {
    return Intl.message(
      'Покажите данную страницу официанту,\nдля корректировки суммы оплаты',
      name: 'show_to_waiter',
      desc: '',
      args: [],
    );
  }

  /// `Сумма счета`
  String get sum_order {
    return Intl.message('Сумма счета', name: 'sum_order', desc: '', args: []);
  }

  /// `Оплачено кешбэком`
  String get payed_by_cashback {
    return Intl.message(
      'Оплачено кешбэком',
      name: 'payed_by_cashback',
      desc: '',
      args: [],
    );
  }

  /// `Итоговая сумма для оплаты:`
  String get total_sum_pay {
    return Intl.message(
      'Итоговая сумма для оплаты:',
      name: 'total_sum_pay',
      desc: '',
      args: [],
    );
  }

  /// `Subjects`
  String get subjects {
    return Intl.message('Subjects', name: 'subjects', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Diagnostics history`
  String get diagnostics_history {
    return Intl.message(
      'Diagnostics history',
      name: 'diagnostics_history',
      desc: '',
      args: [],
    );
  }

  /// `Full name`
  String get full_name {
    return Intl.message('Full name', name: 'full_name', desc: '', args: []);
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Frequently Asked Questions`
  String get faq_title {
    return Intl.message(
      'Frequently Asked Questions',
      name: 'faq_title',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get change_password {
    return Intl.message(
      'Change password',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Image not uploaded`
  String get non_upload_image {
    return Intl.message(
      'Image not uploaded',
      name: 'non_upload_image',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'uz'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalization> load(Locale locale) => AppLocalization.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
