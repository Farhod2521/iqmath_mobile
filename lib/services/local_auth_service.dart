import 'dart:async';
import 'dart:developer';

import 'package:my_flutter_template/services/service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../generated/l10n.dart';

class LocalAuthService implements Service {
  final LocalAuthentication _localAuthentication;
  var _isBiometricsSupported = false;

  LocalAuthService(this._localAuthentication);

  @override
  FutureOr<void> dispose() {
    _localAuthentication.stopAuthentication();
  }

  @override
  FutureOr<void> init() async {
    _isBiometricsSupported = await _localAuthentication.isDeviceSupported();
    log('isBiometricsSupported: $_isBiometricsSupported');
  }

  Future<bool> authenticate(BuildContext context) async {
    final localization = AppLocalization.of(context);
    try {
      return await _localAuthentication.authenticate(
        localizedReason: localization.for_security,
        biometricOnly: true,
      );
    } on PlatformException catch (e) {
      log('Authentication error: ${e.code} - ${e.message}');

      // Error kodlarni to'g'ridan-to'g'ri string sifatida tekshiramiz
      if (e.code == 'NotAvailable') {
        // Biometrics hardware mavjud emas
        return false;
      } else if (e.code == 'NotEnrolled') {
        // Biometrics sozlanmagan
        return false;
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        // Juda ko'p muvaffaqiyatsiz urinishlar
        return false;
      } else if (e.code == 'PasscodeNotSet') {
        // Passcode sozlanmagan
        return false;
      } else {
        // Boshqa xatolar (masalan, user cancel qilgan)
        return false;
      }
    } catch (e) {
      log('Unexpected authentication error: $e');
      return false;
    }
  }

  /// Mavjud biometrics turlarini tekshirish
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuthentication.getAvailableBiometrics();
    } catch (e) {
      log('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Biometrics mavjudligini tekshirish
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuthentication.canCheckBiometrics;
    } catch (e) {
      log('Error checking biometrics: $e');
      return false;
    }
  }

  bool get isBiometricsSupported {
    return _isBiometricsSupported;
  }
}