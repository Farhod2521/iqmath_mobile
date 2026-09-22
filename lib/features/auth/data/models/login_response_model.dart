class LoginResponseModel {
  final num? id;
  final String? fullName;
  final String? phone;
  final String? role;
  final bool? status;
  final String? accessToken;
  final String? refreshToken;
  final num? expiresIn;

  const LoginResponseModel({
    this.id,
    this.fullName,
    this.phone,
    this.role,
    this.status,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      role: json['role'],
      status: json['status'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'status': status,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }

  LoginResponseModel copyWith({
    num? id,
    String? fullName,
    String? phone,
    String? role,
    bool? status,
    String? accessToken,
    String? refreshToken,
    num? expiresIn,
  }) {
    return LoginResponseModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }
}
