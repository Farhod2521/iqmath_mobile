import 'package:my_flutter_template/constants/constants.dart';
import 'package:hive/hive.dart';

class LocalSource {
  final Box<dynamic> box;

  LocalSource(this.box);

  Future<void> clear() async {
    // Qurilma identifikatori saqlanadi — aks holda keyingi kirish yangi
    // qurilma deb hisoblanadi va 2 ta qurilma cheklovida joy egallaydi.
    final deviceId = getDeviceId();
    final deviceRevoked = getDeviceRevoked();
    await box.clear();
    if (deviceId != null && deviceId.isNotEmpty) setDeviceId(deviceId);
    if (deviceRevoked) setDeviceRevoked(true);
  }

  void setDeviceId(String deviceId) {
    box.put(AppKeys.DEVICE_ID, deviceId);
  }

  String? getDeviceId() {
    return box.get(AppKeys.DEVICE_ID);
  }

  /// Qurilma boshqa qurilmadan "Qurilmalar" bo'limi orqali chiqarib
  /// yuborilganini login sahifasida bir marta ko'rsatish uchun belgi.
  void setDeviceRevoked(bool value) {
    box.put(AppKeys.DEVICE_REVOKED, value);
  }

  bool getDeviceRevoked() {
    return box.get(AppKeys.DEVICE_REVOKED) ?? false;
  }

  void setForceUpdate(bool forceUpdate) {
    box.put(AppKeys.FORCEUPDATE, forceUpdate);
  }

  bool getForceUpdate() {
    return box.get(AppKeys.FORCEUPDATE) ?? false;
  }

  void setAppVersion(String appVersion) {
    box.put(AppKeys.APPVERSION, appVersion);
  }

  String? getAppVersion() {
    return box.get(AppKeys.APPVERSION);
  }

  void setLocale(String locale) {
    box.put(AppKeys.LOCALE, locale);
  }

  String? getLocale() {
    return box.get(AppKeys.LOCALE);
  }

  void setRefreshToken(String refreshToken) {
    box.put(AppKeys.REFRESHTOKEN, refreshToken);
  }

  String? getRefreshToken() {
    return box.get(AppKeys.REFRESHTOKEN);
  }

  void setUserId(String userId) {
    box.put(AppKeys.USERID, userId);
  }

  String? getUserId() {
    return box.get(AppKeys.USERID);
  }

  void setPhoneNumber(String phoneNumber) {
    box.put(AppKeys.PHONENUMBER, phoneNumber);
  }

  String? getPhoneNumber() {
    return box.get(AppKeys.PHONENUMBER);
  }

  void setUserPassword(String password) {
    box.put(AppKeys.PASSWORD, password);
  }

  String? getUserPassword() {
    return box.get(AppKeys.PASSWORD);
  }

  void setAccessToken(String accessToken) {
    box.put(AppKeys.ACCESSTOKEN, accessToken);
  }

  String? getAccessToken() {
    return box.get(AppKeys.ACCESSTOKEN);
  }

  void setBiometricsOn(bool isBiometricsOn) {
    box.put(AppKeys.BIOMETRICS_ON, isBiometricsOn);
  }

  bool? getBiometricsOn() {
    return box.get(AppKeys.BIOMETRICS_ON);
  }

  void setFirstName(String firstName) {
    box.put(AppKeys.FIRSTNAME, firstName);
  }

  String? getFirstName() {
    return box.get(AppKeys.FIRSTNAME);
  }

  void setLastName(String lastName) {
    box.put(AppKeys.LASTNAME, lastName);
  }

  String? getLastName() {
    return box.get(AppKeys.LASTNAME);
  }

  void setPinCode(String pinCode) {
    box.put(AppKeys.PINCODE, pinCode);
  }

  String? getPinCode() {
    return box.get(AppKeys.PINCODE);
  }

  void setIsLoggedIn(bool isLoggedIn) {
    box.put(AppKeys.ISLOGGEDIN, isLoggedIn);
  }

  bool? getIsLoggedIn() {
    return box.get(AppKeys.ISLOGGEDIN);
  }

  void setReferralCode(String referralCode) {
    box.put('referral_code', referralCode);
  }

  String? getReferralCode() {
    return box.get('referral_code');
  }

  void setUserIdInt(String userId) {
    box.put('user_id_int', userId);
  }

  String? getUserIdInt() {
    return box.get('user_id_int');
  }

  void setUserAddress(String address) {
    box.put('user_address', address);
  }

  String? getUserAddress() {
    return box.get('user_address');
  }

  void setUserRole(String role) {
    box.put('user_role', role);
  }
  String? getUserRole() {
    return box.get('user_role');
  }

  void setUserProfileID(String profileID) {
    box.put('user_profile_id', profileID);
  }
  String? getUserProfileID() {
    return box.get('user_profile_id');
  }
}
