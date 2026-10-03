import 'package:equatable/equatable.dart';

/// Backend `serialize_device` javobi: login (409 device_limit) va
/// `GET /auth/user/devices/` da bir xil ko'rinishda keladi.
class DeviceItem extends Equatable {
  final String id;
  final String name;
  final String type; // desktop | mobile | tablet | other
  final bool isActive;
  final bool isCurrent;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;
  final DateTime? loggedOutAt;

  const DeviceItem({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
    required this.isCurrent,
    this.createdAt,
    this.lastUsedAt,
    this.loggedOutAt,
  });

  factory DeviceItem.fromJson(Map<String, dynamic> json) => DeviceItem(
        id: json['id']?.toString() ?? '',
        name: (json['device_name'] ?? '').toString(),
        type: (json['device_type'] ?? 'other').toString(),
        isActive: json['is_active'] == true,
        isCurrent: json['is_current'] == true,
        createdAt: _date(json['created_at']),
        lastUsedAt: _date(json['last_used_at']),
        loggedOutAt: _date(json['logged_out_at']),
      );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

  @override
  List<Object?> get props =>
      [id, name, type, isActive, isCurrent, createdAt, lastUsedAt, loggedOutAt];
}

/// Login paytida faol qurilmalar soni chegarasiga yetilganda (HTTP 409,
/// code = device_limit) keladigan ma'lumot.
class DeviceLimitInfo extends Equatable {
  final int maxDevices;
  final List<DeviceItem> devices;

  const DeviceLimitInfo({required this.maxDevices, required this.devices});

  static bool matches(dynamic body) =>
      body is Map && body['code'] == 'device_limit';

  factory DeviceLimitInfo.fromJson(Map<String, dynamic> json) =>
      DeviceLimitInfo(
        maxDevices: (json['max_devices'] as num?)?.toInt() ?? 2,
        devices: ((json['devices'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => DeviceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  @override
  List<Object?> get props => [maxDevices, devices];
}

/// "HH:mm, dd.MM.yyyy" — saytdagi `formatDeviceDate` bilan bir xil.
String formatDeviceDate(DateTime? date) {
  if (date == null) return '—';
  String pad(int n) => n.toString().padLeft(2, '0');
  return '${pad(date.hour)}:${pad(date.minute)}, '
      '${pad(date.day)}.${pad(date.month)}.${date.year}';
}
