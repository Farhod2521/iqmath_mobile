import 'dart:developer';
import 'dart:io';

import 'package:my_flutter_template/generated/l10n.dart';

// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseFunctions {
  BaseFunctions._();

  static FilteringTextInputFormatter get onlyLettersFormatter {
    return FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z\u00C0-\u1FFF\u2C00-\uD7FF]+'));
  }

  static String formatPhoneNumber(String? phoneNumber, {String format = '-'}) {
    if (phoneNumber == null) return "empty";
    if (phoneNumber.length == 13 && phoneNumber.contains(RegExp(r"\d"))) {
      final countryCode = phoneNumber.substring(0, 4);
      final firstPart = phoneNumber.substring(4, 6);
      final secondPart = phoneNumber.substring(6, 9);
      final thirdPart = phoneNumber.substring(9, 11);
      final fourthPart = phoneNumber.substring(11);
      return "$countryCode $firstPart $secondPart$format$thirdPart$format$fourthPart";
    } else {
      return phoneNumber;
    }
  }

  static String moneyFormat(num number) {
    final isNegative = number.isNegative;
    number = number.abs();
    String result = "0";
    result = NumberFormat().format(number).split(",").join(" ");
    return isNegative ? "-$result" : result;
  }

  static String moneyFormatSymbol(num number) {
    final isNegative = number.isNegative;
    number = number.abs();
    String result = "0";
    result = NumberFormat().format(number).split(",").join(" ");
    return "${isNegative ? "-$result" : result} ${"sum"}";
  }

  static String getDefaultLocale() {
    final String defaultSystemLocale = Platform.localeName;
    switch (defaultSystemLocale.split("_").first) {
      case "ru":
        return "ru";
      case "en":
        return "en";
      case "uz":
        return "uz";
      default:
        return "ru";
    }
  }

  static String dateFormatter(String? str, {String? format = "dd.MM.yyyy"}) {
    if (str == null) return "empty";
    try {
      DateTime date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(str);
      return DateFormat(format).format(date);
    } catch (e) {
      log(e.toString());
      return "wrong date format";
    }
  }

  static String timeFormatter(String? str, {String? format = "HH:mm"}) {
    if (str == null) return "empty";
    try {
      DateTime date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(str);
      return DateFormat(format).format(date);
    } catch (e) {
      log(e.toString());
      return "wrong date format";
    }
  }

  static String addressFormatter(String address) {
    String finished = address.replaceAll("ʻ", "'");
    return finished;
  }

  static String welcomeLocalization(BuildContext context) {
    final localization = AppLocalization.of(context);
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) {
      return localization.good_morning;
    } else if (hour >= 10 && hour < 17) {
      return localization.good_afternoon;
    } else if (hour >= 17 && hour < 22) {
      return localization.good_evening;
    } else {
      return localization.good_night;
    }
  }

  static String getLocaleIndexFromList(
      {required int length, required int index, required String locale}) {
    if (locale == "ru") {
      return "$index из $length";
    } else if (locale == "uz") {
      return "$length dan $index";
    } else {
      return "$index of $length";
    }
  }

  // static Future<void> launchUrlStart({required String url}) async {
  //   if (!await launchUrl(Uri.parse(url),
  //       mode: LaunchMode.externalApplication)) {
  //     throw 'Could not launch $url';
  //   }
  // }
  static Future<void> launchUrlStart({required String url}) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  static String getLanguageText({
    required String? languageCode,
    required String? uz,
    required String? ru,
  }) {
    if (languageCode == null) return "empty";
    switch (languageCode) {
      case "ru":
        return ru ?? '';
      case "uz":
        return uz ?? '';
      default:
        return "";
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  static void sendEmail(String email) async {
    if (email.isEmpty) return;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent('IQMATH ilovasidan murojaat')}&'
          'body=${Uri.encodeComponent('Assalomu alaykum,\n\nSizning xizmatlaringiz haqida ma\'lumot olmoqchiman.\n\nRahmat.')}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
// static bool checkSessionIdNotExpired(String sessionExpirationDate) {
//   try {
//     final now = getTimeInTimezone();
//     var sessionExpiration = DateTime.parse(sessionExpirationDate);
//     var isExpired = now.isAfter(sessionExpiration);
//     return !isExpired;
//   } catch (e) {
//     return false;
//   }
// }

// static DateTime getTimeInTimezone([String location = 'Europe/Moscow']) {
//   var moscow = getLocation(location);
//   var now = TZDateTime.now(moscow);
//   DateTime nowDateTime = now.copyWith(
//     year: now.year,
//     month: now.month,
//     day: now.day,
//     hour: now.hour,
//     minute: now.minute,
//     second: now.second,
//     millisecond: now.millisecond,
//     microsecond: now.microsecond,
//   );
//   return nowDateTime;
// }

// static String getLongDeadline(String? deadline) {
//   if (deadline == null) {
//     return "empty";
//   }
//   var newDeadline = DateTime.tryParse(deadline);
//   if (newDeadline == null) {
//     return "incorrect format";
//   }
//   var now = BaseFunctions.getTimeInTimezone();
//   Duration difference = newDeadline.difference(now).abs();
//   if (difference.inDays > 0) {
//     return "${difference.inDays} д. ${difference.inHours % 24} ч. ${difference.inMinutes % 60} мин. до снятия резерва";
//   } else if (difference.inHours > 0) {
//     return "${difference.inHours % 24} ч. ${difference.inMinutes % 60} мин. до снятия резерва";
//   } else if (difference.inMinutes > 0) {
//     return "${difference.inMinutes % 60} мин. до снятия резерва";
//   } else if (difference.inSeconds > 0) {
//     return "${difference.inSeconds % 60} сек. до снятия резерва";
//   } else {
//     return "снятие резерва";
//   }
// }
//
// static String getShortDeadline(String? deadline) {
//   if (deadline == null) {
//     return "empty";
//   }
//   var newDeadline = DateTime.tryParse(deadline);
//   if (newDeadline == null) {
//     return "incorrect format";
//   }
//   var now = BaseFunctions.getTimeInTimezone();
//   Duration difference = newDeadline.difference(now).abs();
//   if (difference.inDays > 0) {
//     return "через ${difference.inDays} дней";
//   } else if (difference.inHours > 0) {
//     return "через ${difference.inHours % 24} часов";
//   } else if (difference.inMinutes > 0) {
//     return "через ${difference.inMinutes % 60} минут";
//   } else if (difference.inSeconds > 0) {
//     return "через ${difference.inSeconds % 60} секунд";
//   } else {
//     return "снятие резерва";
//   }
// }
}
