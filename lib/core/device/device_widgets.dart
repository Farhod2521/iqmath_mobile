import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'device_model.dart';

/// Qurilmalar funksiyasi matnlari (saytdagi `devices.*` tarjimalari bilan bir xil).
class DeviceTexts {
  DeviceTexts._();

  static const Map<String, Map<String, String>> _texts = {
    'uz': {
      'tab': 'Qurilmalar',
      'tabSub': 'Hisobingizga kirilgan qurilmalar',
      'title': 'Faol qurilmalar',
      'limitInfo':
          "Hisobingizga bir vaqtda ko'pi bilan {count} ta qurilmadan kirish mumkin",
      'activeDevices': 'Faol qurilmalar',
      'filterActive': 'Faol',
      'filterAll': 'Barchasi (tarix bilan)',
      'thisDevice': 'Mazkur qurilma',
      'lastActive': 'Oxirgi faollik: {date}',
      'activatedAt': 'Kirilgan: {date}',
      'loggedOutAt': 'Chiqarilgan: {date}',
      'remove': "O'chirish",
      'cancel': 'Bekor qilish',
      'removed': 'Qurilma hisobingizdan chiqarildi',
      'removeError': "Qurilmani o'chirib bo'lmadi",
      'loadError': "Qurilmalarni yuklab bo'lmadi",
      'retry': 'Qayta urinish',
      'empty': "Qurilmalar yo'q",
      'confirmTitle': 'Qurilmani chiqarib yuborasizmi?',
      'confirmText':
          "\"{name}\" qurilmasi hisobingizdan chiqariladi va u yerda qaytadan kirish kerak bo'ladi.",
      'limitTitle': 'Qurilmalar soni chegarasiga yetildi',
      'limitText':
          "Hisobingizga bir vaqtda ko'pi bilan {count} ta qurilmadan kirish mumkin. Shu qurilmadan kirish uchun quyidagilardan birini chiqarib yuboring.",
      'limitHint': 'Chiqarilgan qurilmada hisobingizdan avtomatik chiqib ketiladi.',
      'revoked':
          'Bu qurilma hisobingizdan chiqarib yuborilgan. Qaytadan kiring.',
    },
    'ru': {
      'tab': 'Устройства',
      'tabSub': 'Устройства, с которых выполнен вход',
      'title': 'Активные устройства',
      'limitInfo':
          'В аккаунт можно войти одновременно не более чем с {count} устройств',
      'activeDevices': 'Активные устройства',
      'filterActive': 'Активные',
      'filterAll': 'Все (с историей)',
      'thisDevice': 'Это устройство',
      'lastActive': 'Последняя активность: {date}',
      'activatedAt': 'Вход: {date}',
      'loggedOutAt': 'Выход: {date}',
      'remove': 'Удалить',
      'cancel': 'Отмена',
      'removed': 'Устройство отключено от аккаунта',
      'removeError': 'Не удалось удалить устройство',
      'loadError': 'Не удалось загрузить устройства',
      'retry': 'Повторить',
      'empty': 'Устройств нет',
      'confirmTitle': 'Отключить устройство?',
      'confirmText':
          'Устройство «{name}» будет отключено от аккаунта, на нём потребуется войти заново.',
      'limitTitle': 'Достигнут лимит устройств',
      'limitText':
          'В аккаунт можно войти одновременно не более чем с {count} устройств. Чтобы войти с этого устройства, отключите одно из них.',
      'limitHint':
          'На отключённом устройстве произойдёт автоматический выход из аккаунта.',
      'revoked': 'Это устройство было отключено от аккаунта. Войдите заново.',
    },
  };

  static String get(String? locale, String key, [Map<String, String>? args]) {
    var text = (_texts[locale == 'ru' ? 'ru' : 'uz']?[key]) ?? key;
    args?.forEach((name, value) => text = text.replaceAll('{$name}', value));
    return text;
  }
}

/// Qurilma turi ikonkasi (faol — ko'k gradient, chiqarilgan — kulrang).
class DeviceIcon extends StatelessWidget {
  final String type;
  final bool active;

  const DeviceIcon({super.key, required this.type, this.active = true});

  IconData get _icon {
    switch (type) {
      case 'desktop':
        return Icons.desktop_windows_rounded;
      case 'mobile':
        return Icons.smartphone_rounded;
      case 'tablet':
        return Icons.tablet_android_rounded;
      default:
        return Icons.laptop_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: active ? null : const Color(0xFFCBD5E1),
        gradient: active
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
              )
            : null,
      ),
      child: Icon(_icon, color: Colors.white, size: 22),
    );
  }
}

/// Login paytida 2 ta qurilma chegarasiga yetilganda ochiladigan pastki panel:
/// foydalanuvchi qurilmalardan birini chiqarib yuboradi va shu qurilmadan
/// kiradi (login `replace_device_id` bilan qayta yuboriladi).
class DeviceLimitSheet extends StatefulWidget {
  final DeviceLimitInfo info;
  final String phoneNumber;
  final String password;
  final String? locale;

  const DeviceLimitSheet({
    super.key,
    required this.info,
    required this.phoneNumber,
    required this.password,
    required this.locale,
  });

  /// [bloc] — login sahifasidagi AuthBloc (pastki panel alohida route'da
  /// ochilgani uchun unga qo'lda uzatiladi).
  static Future<void> show(
    BuildContext context, {
    required AuthBloc bloc,
    required DeviceLimitInfo info,
    required String phoneNumber,
    required String password,
    required String? locale,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: DeviceLimitSheet(
          info: info,
          phoneNumber: phoneNumber,
          password: password,
          locale: locale,
        ),
      ),
    );
  }

  @override
  State<DeviceLimitSheet> createState() => _DeviceLimitSheetState();
}

class _DeviceLimitSheetState extends State<DeviceLimitSheet> {
  late DeviceLimitInfo _info = widget.info;
  String? _removingId;

  String _t(String key, [Map<String, String>? args]) =>
      DeviceTexts.get(widget.locale, key, args);

  void _remove(DeviceItem device) {
    if (_removingId != null) return;
    setState(() => _removingId = device.id);
    context.read<AuthBloc>().add(
          AuthLoginEvent(
            phoneNumber: widget.phoneNumber,
            password: widget.password,
            replaceDeviceId: device.id,
          ),
        );
  }

  void _close() {
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.stateStatus.isDeviceLimit && state.deviceLimit != null) {
          // Ro'yxat o'zgargan bo'lsa (masalan, boshqa qurilmadan kirildi)
          setState(() {
            _info = state.deviceLimit!;
            _removingId = null;
          });
        } else if (state.stateStatus.isError || state.stateStatus.isSuccess) {
          // Xato yoki muvaffaqiyatli kirish — panel yopiladi, qolganini
          // login sahifasi hal qiladi (xabar / keyingi sahifaga o'tish).
          _close();
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tutqich va yopish tugmasi
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _removingId == null ? _close : null,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: Color(0xFF6B7385)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Sarlavha
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFFFFBEB), width: 8),
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: Color(0xFFD97706), size: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _t('limitTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t('limitText', {'count': '${_info.maxDevices}'}),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF5B6478),
                ),
              ),
              const SizedBox(height: 22),

              // Qurilmalar
              for (final device in _info.devices) ...[
                _deviceCard(device),
                const SizedBox(height: 12),
              ],

              // Izoh
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: Color(0xFF3B5BAA)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _t('limitHint'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Color(0xFF3B5BAA),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deviceCard(DeviceItem device) {
    final removing = _removingId == device.id;
    final canRemove = device.isActive && !device.isCurrent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF1F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeviceIcon(type: device.type, active: device.isActive),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 13, color: Color(0xFF8A93A6)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _t('lastActive', {
                              'date': formatDeviceDate(device.lastUsedAt),
                            }),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A93A6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canRemove) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: _removingId == null ? () => _remove(device) : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  backgroundColor: Colors.white,
                  disabledForegroundColor:
                      const Color(0xFFEF4444).withValues(alpha: 0.5),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: removing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFEF4444),
                        ),
                      )
                    : const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(_t('remove')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
