part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationItemData>? notificationItems;
  final ({String? title, String? message})? errorMessage;

  const NotificationState({
    this.notificationItems,
    this.status = NotificationStatus.idle,
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationItemData>? notificationItems,
    ({String? title, String? message})? errorMessage,
  }) {
    return NotificationState(
      status: status ?? NotificationStatus.idle,
      notificationItems: notificationItems ?? this.notificationItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [notificationItems, status, errorMessage];
}

enum NotificationStatus { idle, loading, success, error }

extension NotificationStatusX on NotificationStatus {
  bool get isLoading => this == NotificationStatus.loading;

  bool get isSuccess => this == NotificationStatus.success;

  bool get isError => this == NotificationStatus.error;

  bool get isIdle => this == NotificationStatus.idle;
}

class NotificationItemData {
  final String title;
  final String subtitle;
  final DateTime dateTime;

  const NotificationItemData({
    required this.title,
    required this.subtitle,
    required this.dateTime,
  });
}

final notificationItems = [
  NotificationItemData(
    title: 'Доступное новое обновление',
    subtitle:
        'Это обновление содержит важные исправления ошибок, относящихся к системе безопасности. Оно рекомендуется для установки всем пользователям.',
    dateTime: DateTime.now(),
  ),
  NotificationItemData(
    title: 'Доступное новое обновление',
    subtitle:
        'Это обновление содержит важные исправления ошибок, относящихся к системе безопасности. Оно рекомендуется для установки всем пользователям.',
    dateTime: DateTime.now(),
  ),
  NotificationItemData(
    title: 'Доступное новое обновление',
    subtitle:
        'Это обновление содержит важные исправления ошибок, относящихся к системе безопасности. Оно рекомендуется для установки всем пользователям.',
    dateTime: DateTime.now(),
  ),
  NotificationItemData(
    title: 'Доступное новое обновление',
    subtitle:
        'Это обновление содержит важные исправления ошибок, относящихся к системе безопасности. Оно рекомендуется для установки всем пользователям.',
    dateTime: DateTime.now(),
  ),
  NotificationItemData(
    title: 'Доступное новое обновление',
    subtitle:
        'Это обновление содержит важные исправления ошибок, относящихся к системе безопасности. Оно рекомендуется для установки всем пользователям.',
    dateTime: DateTime.now(),
  ),
];
