import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../constants/constants.dart';
import '../../core/local_source/local_source.dart';
import '../../core/widgets/dash_ui.dart';
import '../../injector_container.dart';

/// Gol, kundalik mukofot, hamyon tarixi va tarif (Start / Start Pro) — sayt bilan bir xil API.
///
///   POST /func_student/daily-reward/claim/   — bugungi +1 gol (takroriy chaqiruv qo'shmaydi)
///   GET  /func_student/daily-reward/         — holat va jami gol
///   GET  /func_student/wallet-history/       — Tarix: ?currency=&date_from=&date_to=&page=
///   GET  /payments/subscription/trial_days/  — tarif: tariff.is_pro / trial_tariff.is_pro
class RewardsApi {
  RewardsApi._();

  static Dio get _dio => sl<Dio>();

  static Future<Map<String, dynamic>> claimDaily() async {
    final res = await _dio.post('${Constants.baseUrl}/func_student/daily-reward/claim/');
    final data = asMap(res.data);
    GolStore.set(data['gol_total']);
    return data;
  }

  static Future<Map<String, dynamic>> dailyStatus() async {
    final res = await _dio.get('${Constants.baseUrl}/func_student/daily-reward/');
    final data = asMap(res.data);
    GolStore.set(data['gol_total']);
    return data;
  }

  static Future<Map<String, dynamic>> walletHistory({
    String? currency,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    String day(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final res = await _dio.get(
      '${Constants.baseUrl}/func_student/wallet-history/',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (currency != null) 'currency': currency,
        if (dateFrom != null) 'date_from': day(dateFrom),
        if (dateTo != null) 'date_to': day(dateTo),
      },
    );
    final data = asMap(res.data);
    GolStore.set(asMap(data['summary'])['gol']);
    return data;
  }

  static Future<Map<String, dynamic>> subscription() async {
    final res = await _dio.get('${Constants.baseUrl}/payments/subscription/trial_days/');
    return asMap(res.data is Map && res.data['data'] is Map ? res.data['data'] : res.data);
  }
}

/// Jami gol — bosh sahifa, profil va Tarix bir xil qiymatni ko'rsatadi.
class GolStore {
  GolStore._();

  static final ValueNotifier<int?> total = ValueNotifier<int?>(null);

  static void set(dynamic value) {
    if (value == null) return;
    total.value = asInt(value);
  }

  static Future<void> refresh() async {
    try {
      await RewardsApi.dailyStatus();
    } catch (_) {}
  }
}

/// O'quvchi tarifi. isPro:
///   to'langan Start Pro → true, to'langan Start → false,
///   sinov muddati → admin tanlagan default tarif (trial_tariff), muddati tugagan → false.
/// Qiymat `null` — hali yuklanmagan (Pro imkoniyatlari ko'rsatilmaydi, saytdagi kabi).
class TariffService {
  TariffService._();

  static final ValueNotifier<bool?> isPro = ValueNotifier<bool?>(null);
  static final ValueNotifier<String> tariffName = ValueNotifier<String>('');

  static bool get isStudent => (sl<LocalSource>().getUserRole() ?? 'student') == 'student';

  static Future<void> load({String locale = 'uz'}) async {
    if (!isStudent) return;
    try {
      final sub = await RewardsApi.subscription();
      final tariff = sub['tariff'] is Map ? asMap(sub['tariff']) : null;
      final trial = sub['trial_tariff'] is Map ? asMap(sub['trial_tariff']) : null;
      final daysLeft = asInt(sub['days_until_next_payment']);
      final active = sub['is_paid'] == true || daysLeft > 0;
      isPro.value = active && (tariff != null ? tariff['is_pro'] == true : trial != null ? trial['is_pro'] == true : true);
      tariffName.value = tariff != null
          ? '${(locale == 'ru' ? tariff['name_ru'] : tariff['name_uz']) ?? tariff['name'] ?? ''}'
          : '${trial?['name'] ?? ''}';
    } catch (_) {
      // Tarmoq xatosi: oldingi qiymat saqlanadi
    }
  }
}
