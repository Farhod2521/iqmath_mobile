import 'package:equatable/equatable.dart';
import 'package:my_flutter_template/features/main/data/models/user_response.dart';

class UserResponseEntity extends Equatable {
  final int? id;
  final String? identification;
  final String? fullName;
  final String? phone;
  final String? email;
  final int? telegramId;
  final String? region;
  final String? districts;
  final String? address;
  final String? birthday;
  final String? academyOrSchool;
  final String? academyOrSchoolName;
  final String? classNameUz;
  final String? classNameRu;
  final String? documentType;
  final String? document;
  final String? typeOfEducation;
  final String? studentDate;
  final String? studentTime;
  final String? role;
  final bool? hasDiagnost;
  final String? avatar; // profil rasmi URL'i

  const UserResponseEntity({
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

  @override
  List<Object?> get props => [
    id,
    identification,
    fullName,
    phone,
    email,
    telegramId,
    region,
    districts,
    address,
    birthday,
    academyOrSchool,
    academyOrSchoolName,
    classNameUz,
    classNameRu,
    documentType,
    document,
    typeOfEducation,
    studentDate,
    studentTime,
    role,
    hasDiagnost,
    avatar,
  ];
}

extension UserResponseEntityX on UserResponse {
  UserResponseEntity get toEntity {
    return UserResponseEntity(
      id: id,
      identification: identification,
      fullName: fullName,
      phone: phone,
      email: email,
      telegramId: telegramId,
      region: region,
      districts: districts,
      address: address,
      birthday: birthday,
      academyOrSchool: academyOrSchool,
      academyOrSchoolName: academyOrSchoolName,
      classNameUz: classNameUz,
      classNameRu: classNameRu,
      documentType: documentType,
      document: document,
      typeOfEducation: typeOfEducation,
      studentDate: studentDate,
      studentTime: studentTime,
      role: role,
      hasDiagnost: hasDiagnost,
      avatar: avatar,
    );
  }
}
