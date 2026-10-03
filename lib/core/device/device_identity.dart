import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../local_source/local_source.dart';

/// Qurilma identifikatsiyasi — saytdagi `shared/utils/device.js` ning mobil
/// ekvivalenti. Backend o'quvchiga bir vaqtda ko'pi bilan 2 ta qurilmadan
/// kirishga ruxsat beradi va qurilmani shu ma'lumotlar bo'yicha taniydi:
///   device_id   — ilova o'rnatilganda bir marta yaratiladigan doimiy UUID
///                 (chiqishda ham o'chirilmaydi, aks holda har kirish yangi
///                 qurilma deb hisoblanadi);
///   device_name — "Samsung SM-A515F" kabi tayyor nom;
///   user_agent  — backend qurilma turini (mobile/tablet) aniqlashi uchun.
class DeviceIdentity {
  DeviceIdentity._();

  static String? _name;
  static String? _userAgent;

  /// Doimiy qurilma identifikatori (birinchi chaqiruvda yaratiladi).
  static String deviceId(LocalSource localSource) {
    final saved = localSource.getDeviceId();
    if (saved != null && saved.isNotEmpty) return saved;
    final id = _uuidV4();
    localSource.setDeviceId(id);
    return id;
  }

  /// Qurilma nomi va User-Agent ni bir marta aniqlab, keshlab qo'yadi.
  /// Ilova ishga tushganda chaqiriladi — login paytida kutib turilmaydi.
  static Future<void> init() async {
    if (_name != null) return;
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        final brand = _capitalize(info.manufacturer);
        final model = info.model;
        _name = model.toLowerCase().startsWith(brand.toLowerCase())
            ? model
            : '$brand $model'.trim();
        _userAgent = 'Mozilla/5.0 (Linux; Android ${info.version.release}; '
            '$model) IQMathApp Mobile';
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        final isPad = info.model.toLowerCase().contains('ipad');
        final version = info.systemVersion.replaceAll('.', '_');
        _name = info.utsname.machine.isNotEmpty
            ? '${info.model} (${info.utsname.machine})'
            : info.model;
        _userAgent = isPad
            ? 'Mozilla/5.0 (iPad; CPU OS $version like Mac OS X) IQMathApp'
            : 'Mozilla/5.0 (iPhone; CPU iPhone OS $version like Mac OS X) '
                'IQMathApp Mobile';
      }
    } catch (e) {
      debugPrint('DeviceIdentity: qurilma ma\'lumotini olib bo\'lmadi: $e');
    }
    _name ??= Platform.isIOS ? 'iPhone' : 'Android';
    _userAgent ??= Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS like Mac OS X) IQMathApp Mobile'
        : 'Mozilla/5.0 (Linux; Android) IQMathApp Mobile';
  }

  static String get deviceName => _name ?? (Platform.isIOS ? 'iPhone' : 'Android');

  static String get userAgent =>
      _userAgent ?? 'Mozilla/5.0 (Linux; Android) IQMathApp Mobile';

  /// Login / SMS tasdiqlash so'rovlariga qo'shiladigan maydonlar.
  static Map<String, String> credentials(LocalSource localSource) => {
        'device_id': deviceId(localSource),
        'device_name': deviceName,
        'user_agent': userAgent,
      };

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  static String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // versiya 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
