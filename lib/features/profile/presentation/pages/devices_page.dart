import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/constants.dart';
import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/device/device_model.dart';
import '../../../../core/device/device_widgets.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../../../injector_container.dart';

const Color _kPrimary = Color(0xFF2563EB);
const Color _kInk = Color(0xFF191C1D);
const Color _kMuted = Color(0xFF5B6478);
const Color _kSubtle = Color(0xFF8A93A6);
const Color _kBorder = Color(0xFFEEF1F6);
const Color _kDanger = Color(0xFFEF4444);

/// Profil → "Qurilmalar": hisobga kirilgan qurilmalar va ularni chiqarib
/// yuborish (saytdagi DevicesTab bilan bir xil API va mantiq).
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final Dio _dio = sl<Dio>();

  String _status = 'active'; // active | all
  bool _loading = true;
  bool _failed = false;
  int _maxDevices = 2;
  int _activeCount = 0;
  List<DeviceItem> _devices = const [];
  String? _removingId;

  String get _locale => context.read<AppBloc>().state.appLocale ?? 'uz';

  String _t(String key, [Map<String, String>? args]) =>
      DeviceTexts.get(_locale, key, args);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _devices.isEmpty;
      _failed = false;
    });
    try {
      final response = await _dio.get(
        '${Constants.baseUrl}${Urls.MY_DEVICES}',
        queryParameters: {'status': _status},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final devices = ((data['devices'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => DeviceItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _maxDevices = (data['max_devices'] as num?)?.toInt() ?? 2;
        _activeCount = (data['active_count'] as num?)?.toInt() ??
            devices.where((d) => d.isActive).length;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _setStatus(String status) {
    if (status == _status) return;
    HapticFeedback.selectionClick();
    setState(() {
      _status = status;
      _devices = const [];
    });
    _load();
  }

  Future<void> _remove(DeviceItem device) async {
    setState(() => _removingId = device.id);
    try {
      await _dio.delete('${Constants.baseUrl}${Urls.MY_DEVICES}${device.id}/');
      if (!mounted) return;
      TopNotification.showSuccess(context, message: _t('removed'));
      await _load();
    } catch (_) {
      if (!mounted) return;
      TopNotification.showError(context, message: _t('removeError'));
    } finally {
      if (mounted) setState(() => _removingId = null);
    }
  }

  Future<void> _confirmRemove(DeviceItem device) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ConfirmSheet(
        title: _t('confirmTitle'),
        text: _t('confirmText', {'name': device.name}),
        cancel: _t('cancel'),
        confirm: _t('remove'),
      ),
    );
    if (confirmed == true) await _remove(device);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            foregroundColor: _kInk,
            title: Text(
              _t('tab'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kInk,
              ),
            ),
          ),
          body: RefreshIndicator(
            color: _kPrimary,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _statusCard(),
                const SizedBox(height: 16),
                _filter(),
                const SizedBox(height: 14),
                ..._content(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusCard() {
    final full = _activeCount >= _maxDevices;
    final ratio =
        _maxDevices > 0 ? (_activeCount / _maxDevices).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF4FF), Color(0xFFF8FAFF)],
        ),
        border: Border.all(color: const Color(0xFFE3EBFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimary.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.verified_user_rounded,
                    color: _kPrimary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _t('limitInfo', {'count': '$_maxDevices'}),
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: _kMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _t('activeDevices'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kMuted,
                ),
              ),
              const Spacer(),
              Text(
                '$_activeCount / $_maxDevices',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: full ? const Color(0xFFD97706) : _kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(
                full ? const Color(0xFFF59E0B) : _kPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filter() {
    Widget chip(String value, String label) {
      final selected = _status == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => _setStatus(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _kPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _kMuted,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          chip('active', _t('filterActive')),
          const SizedBox(width: 4),
          chip('all', _t('filterAll')),
        ],
      ),
    );
  }

  List<Widget> _content() {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator(color: _kPrimary)),
        ),
      ];
    }
    if (_failed) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, size: 40, color: _kSubtle),
              const SizedBox(height: 10),
              Text(_t('loadError'),
                  style: const TextStyle(fontSize: 14, color: _kMuted)),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: Text(_t('retry'))),
            ],
          ),
        ),
      ];
    }
    if (_devices.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: Text(_t('empty'),
                style: const TextStyle(fontSize: 14, color: _kSubtle)),
          ),
        ),
      ];
    }
    return [
      for (final device in _devices) ...[
        _deviceCard(device),
        const SizedBox(height: 12),
      ],
    ];
  }

  Widget _deviceCard(DeviceItem device) {
    final removing = _removingId == device.id;
    final canRemove = device.isActive && !device.isCurrent;

    final Widget status;
    if (device.isCurrent) {
      status = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _t('thisDevice'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16A34A),
            ),
          ),
        ],
      );
    } else if (!device.isActive) {
      status = Text(
        _t('loggedOutAt', {'date': formatDeviceDate(device.loggedOutAt)}),
        style: const TextStyle(fontSize: 12, color: _kSubtle),
      );
    } else {
      status = Text(
        _t('lastActive', {'date': formatDeviceDate(device.lastUsedAt)}),
        style: const TextStyle(fontSize: 12, color: _kSubtle),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: device.isCurrent ? const Color(0xFFBBF7D0) : _kBorder,
        ),
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: device.isActive ? _kInk : _kMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    status,
                    const SizedBox(height: 2),
                    Text(
                      _t('activatedAt',
                          {'date': formatDeviceDate(device.createdAt)}),
                      style: const TextStyle(fontSize: 12, color: _kSubtle),
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
                onPressed: _removingId == null
                    ? () => _confirmRemove(device)
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kDanger,
                  disabledForegroundColor: _kDanger.withValues(alpha: 0.5),
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
                          color: _kDanger,
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

/// "Qurilmani chiqarib yuborasizmi?" — pastki tasdiqlash paneli.
class _ConfirmSheet extends StatelessWidget {
  final String title;
  final String text;
  final String cancel;
  final String confirm;

  const _ConfirmSheet({
    required this.title,
    required this.text,
    required this.cancel,
    required this.confirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: _kDanger, size: 26),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.45, color: _kMuted),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kInk,
                      side: const BorderSide(color: Color(0xFFE5EAF2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(cancel,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kDanger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(confirm,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
