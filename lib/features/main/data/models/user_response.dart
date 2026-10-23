class UserResponse {
  UserResponse({
    this.id,
    this.identification,
    this.fullName,
    this.phone,
    this.email,
    this.telegramId,
    this.region,
    this.districts,
    this.address,
    this.birthday,
    this.academyOrSchool,
    this.academyOrSchoolName,
    this.classNameUz,
    this.classNameRu,
    this.documentType,
    this.document,
    this.typeOfEducation,
    this.studentDate,
    this.studentTime,
    this.role,
    this.hasDiagnost,
    this.avatar,
  });

  UserResponse.fromJson(dynamic json) {
    id = json['id'];
    identification = json['identification'];
    fullName = json['full_name'];
    phone = json['phone'];
    email = json['email'];
    telegramId = json['telegram_id'];
    region = json['region'];
    districts = json['districts'];
    address = json['address'];
    birthday = json['brithday']; // JSON’da typo: "brithday"
    academyOrSchool = json['academy_or_school'];
    academyOrSchoolName = json['academy_or_school_name'];
    classNameUz = json['class_name_uz'];
    classNameRu = json['class_name_ru'];
    documentType = json['document_type'];
    document = json['document'];
    typeOfEducation = json['type_of_education'];
    studentDate = json['student_date'];
    studentTime = json['student_time'];
    role = json['role'];
    hasDiagnost = json['has_diagnost'];
    avatar = json['avatar'];
  }

  int? id;
  String? identification;
  String? fullName;
  String? phone;
  String? email;
  int? telegramId;
  String? region;
  String? districts;
  String? address;
  String? birthday;
  String? academyOrSchool;
  String? academyOrSchoolName;
  String? classNameUz;
  String? classNameRu;
  String? documentType;
  String? document;
  String? typeOfEducation;
  String? studentDate;
  String? studentTime;
  String? role;
  bool? hasDiagnost;
  String? avatar; // profil rasmi URL'i

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['identification'] = identification;
    map['full_name'] = fullName;
    map['phone'] = phone;
    map['email'] = email;
    map['telegram_id'] = telegramId;
    map['region'] = region;
    map['districts'] = districts;
    map['address'] = address;
    map['brithday'] = birthday;
    map['academy_or_school'] = academyOrSchool;
    map['academy_or_school_name'] = academyOrSchoolName;
    map['class_name_uz'] = classNameUz;
    map['class_name_ru'] = classNameRu;
    map['document_type'] = documentType;
    map['document'] = document;
    map['type_of_education'] = typeOfEducation;
    map['student_date'] = studentDate;
    map['student_time'] = studentTime;
    map['role'] = role;
    map['has_diagnost'] = hasDiagnost;
    map['avatar'] = avatar;
    return map;
  }
}
