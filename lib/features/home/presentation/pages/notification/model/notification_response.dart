class NotificationItemModel {
  final int id;
  final String? titleUz;
  final String? titleRu;
  final String? textUz;
  final String? textRu;
  final String? image;
  final String? video;
  final List<int> categories;
  final List<int> tagIds;
  final bool notificationStatus;
  final bool newsStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationItemModel({
    required this.id,
    this.titleUz,
    this.titleRu,
    this.textUz,
    this.textRu,
    this.image,
    this.video,
    required this.categories,
    required this.tagIds,
    required this.notificationStatus,
    required this.newsStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to get localized title
  String getTitle(String locale) {
    if (locale == 'ru' && titleRu != null && titleRu!.isNotEmpty) {
      return titleRu!;
    } else if (titleUz != null && titleUz!.isNotEmpty) {
      return titleUz!;
    }
    return '';
  }

  // Helper method to get localized text
  String getText(String locale) {
    if (locale == 'ru' && textRu != null && textRu!.isNotEmpty) {
      return textRu!;
    } else if (textUz != null && textUz!.isNotEmpty) {
      return textUz!;
    }
    return '';
  }

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as int,
      titleUz: json['title_uz'] as String?,
      titleRu: json['title_ru'] as String?,
      textUz: json['text_uz'] as String?,
      textRu: json['text_ru'] as String?,
      image: json['image'] as String?,
      video: json['video'] as String?,
      categories: (json['categories'] as List<dynamic>).cast<int>(),
      tagIds: (json['tags'] as List<dynamic>).cast<int>(),
      notificationStatus: json['notification_status'] as bool,
      newsStatus: json['news_status'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_uz': titleUz,
      'title_ru': titleRu,
      'text_uz': textUz,
      'text_ru': textRu,
      'image': image,
      'video': video,
      'categories': categories,
      'tags': tagIds,
      'notification_status': notificationStatus,
      'news_status': newsStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}