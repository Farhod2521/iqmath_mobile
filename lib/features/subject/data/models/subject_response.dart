/// id : 2
/// name_uz : "Matematika"
/// name_ru : "Математика"
/// class_name : "5"
/// class_uz : "5-sinf Matematika"
/// class_ru : "5-класс Математика"
/// image_uz : "/FILES/SubjectUZ/5-sinf-uz_uc0lAWO.jpg"
/// image_ru : "/FILES/SubjectRU/5-sinf-rus.jpg"
/// is_open : true
/// is_diagnost_open : true

class SubjectResponse {
  SubjectResponse({
      num? id,
      String? nameUz,
      String? nameRu,
      String? className,
      String? classUz,
      String? classRu,
      String? imageUz,
      String? imageRu,
      bool? isOpen,
      bool? isDiagnostOpen,
      num? topicsCount,
      num? questionsCount,
      num? progress,
      num? completedTopics,
      num? inProgressTopics,}){
    _id = id;
    _nameUz = nameUz;
    _nameRu = nameRu;
    _className = className;
    _classUz = classUz;
    _classRu = classRu;
    _imageUz = imageUz;
    _imageRu = imageRu;
    _isOpen = isOpen;
    _isDiagnostOpen = isDiagnostOpen;
    _topicsCount = topicsCount;
    _questionsCount = questionsCount;
    _progress = progress;
    _completedTopics = completedTopics;
    _inProgressTopics = inProgressTopics;
}

  SubjectResponse.fromJson(dynamic json) {
    _id = json['id'];
    _nameUz = json['name_uz'];
    _nameRu = json['name_ru'];
    _className = json['class_name'];
    _classUz = json['class_uz'];
    _classRu = json['class_ru'];
    _imageUz = json['image_uz'];
    _imageRu = json['image_ru'];
    _isOpen = json['is_open'];
    _isDiagnostOpen = json['is_diagnost_open'];
    _topicsCount = json['topics_count'];
    _questionsCount = json['questions_count'];
    _progress = json['progress'];
    _completedTopics = json['completed_topics'];
    _inProgressTopics = json['in_progress_topics'];
  }
  num? _id;
  String? _nameUz;
  String? _nameRu;
  String? _className;
  String? _classUz;
  String? _classRu;
  String? _imageUz;
  String? _imageRu;
  bool? _isOpen;
  bool? _isDiagnostOpen;
  num? _topicsCount;
  num? _questionsCount;
  num? _progress;
  num? _completedTopics;
  num? _inProgressTopics;
SubjectResponse copyWith({  num? id,
  String? nameUz,
  String? nameRu,
  String? className,
  String? classUz,
  String? classRu,
  String? imageUz,
  String? imageRu,
  bool? isOpen,
  bool? isDiagnostOpen,
  num? topicsCount,
  num? questionsCount,
  num? progress,
  num? completedTopics,
  num? inProgressTopics,
}) => SubjectResponse(  id: id ?? _id,
  nameUz: nameUz ?? _nameUz,
  nameRu: nameRu ?? _nameRu,
  className: className ?? _className,
  classUz: classUz ?? _classUz,
  classRu: classRu ?? _classRu,
  imageUz: imageUz ?? _imageUz,
  imageRu: imageRu ?? _imageRu,
  isOpen: isOpen ?? _isOpen,
  isDiagnostOpen: isDiagnostOpen ?? _isDiagnostOpen,
  topicsCount: topicsCount ?? _topicsCount,
  questionsCount: questionsCount ?? _questionsCount,
  progress: progress ?? _progress,
  completedTopics: completedTopics ?? _completedTopics,
  inProgressTopics: inProgressTopics ?? _inProgressTopics,
);
  num? get id => _id;
  String? get nameUz => _nameUz;
  String? get nameRu => _nameRu;
  String? get className => _className;
  String? get classUz => _classUz;
  String? get classRu => _classRu;
  String? get imageUz => _imageUz;
  String? get imageRu => _imageRu;
  bool? get isOpen => _isOpen;
  bool? get isDiagnostOpen => _isDiagnostOpen;
  num? get topicsCount => _topicsCount;
  num? get questionsCount => _questionsCount;
  num? get progress => _progress;
  num? get completedTopics => _completedTopics;
  num? get inProgressTopics => _inProgressTopics;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name_uz'] = _nameUz;
    map['name_ru'] = _nameRu;
    map['class_name'] = _className;
    map['class_uz'] = _classUz;
    map['class_ru'] = _classRu;
    map['image_uz'] = _imageUz;
    map['image_ru'] = _imageRu;
    map['is_open'] = _isOpen;
    map['is_diagnost_open'] = _isDiagnostOpen;
    map['topics_count'] = _topicsCount;
    map['questions_count'] = _questionsCount;
    map['progress'] = _progress;
    map['completed_topics'] = _completedTopics;
    map['in_progress_topics'] = _inProgressTopics;
    return map;
  }

}