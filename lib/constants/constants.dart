class Constants {
  static const String authUrl = "https://api.iqmath.uz/api/v1";
  static const String baseUrl = "https://api.iqmath.uz/api/v1";
  static const String iosUrl =
      "https://apps.apple.com/uz/app/slash/id6447563629";
  static const String androidUrl = "market://details?id=uz.slash";
  static const String appMetricaKey = "28b33c0b-d306-4202-9b90-64c2d2a0b49b";

  // Battle (1v1 matematik duel) — WebSocket manzili. Xona ID va tokenni
  // `BattleSocketService` o'zi qo'shib ulanadi:
  // wss://api.iqmath.uz/ws/battle/{roomId}/?token={accessToken}
  static const String battleWsBase = "wss://api.iqmath.uz/ws/battle";
}

class AppKeys {
  static const LOCALE = 'locale';
  static const ACCESSTOKEN = 'access_token';
  static const REFRESHTOKEN = 'refresh_token';
  static const FIRSTNAME = 'firstname';
  static const LASTNAME = 'lastname';
  static const EMAIL = 'email';
  static const PASSWORD = 'password';
  static const BIOMETRICS_ON = 'biometrics_on';
  static const PINCODE = 'pin_code';
  static const USERID = 'user_id';
  static const PHONENUMBER = 'phone_number';
  static const APPVERSION = 'app_version';
  static const FORCEUPDATE = 'force_update';
  static const ISLOGGEDIN='is_logged_in';
  static const DEVICE_ID = 'iq_device_id';
  static const DEVICE_REVOKED = 'iq_device_revoked';
}

class Urls {
  static const REGISTER = '/auth/student/register/';
  static const LOGIN = '/auth/student/login/';
  static const CONFIRM = '/auth/student/register-verify-sms/';
  static const RESET= '/auth/student/verify-sms-code/';
  static const ALLBRANCHES = '/v1/branch';
  static const USERINFO = '/auth/student/profile/';
  static const ALLCATEGORIES = '/v1/category';
  static const PRODUCTS = '/products';
  static const ORGANIZATIONRANKS = '/v1/organization_rank';
  static const FAQ = '/v1/faq';
  static const UPLOADIMAGE = '/v1/upload-image';
  static const LIKERESTAURANT = '/v1/branch/favourites';
  static const BRANCHWANTS = '/v1/branch/wants';
  static const BANNERS = '/v1/banner';
  static const QRCODE = '/v1/qr';
  static const ORDERCLOSE = '/v1/order/close';
  static const SUBJECTS = '/func_student/my-subjects/';
  static const UPDATE_USER = '/auth/user/update-profile/';
  // Qurilmalar: GET ro'yxat (?status=active|all), DELETE `${MY_DEVICES}{id}/`
  static const MY_DEVICES = '/auth/user/devices/';

  // Bosh sahifa (dashboard) — iqmath_student veb ilovasi bilan bir xil endpointlar
  static const HOME_DASHBOARD = '/func_student/student/home-dashboard/app';
  static const STUDY_STATS_BY_DATE =
      '/func_student/student/studystats-by-date/app';
  static const RATING = '/func_student/student/rating/app';
  static const MY_SCORE = '/func_student/my-score/';

  // Battle (1v1 matematik duel) — iqmath_student veb ilovasi bilan bir xil
  // endpointlar.
  static const BATTLE_SUBJECTS = '/func_teacher/subject-list/';
  static const BATTLE_ROOM_CREATE = '/battle/rooms/create/';
  static const BATTLE_ROOM_JOIN = '/battle/rooms/join/';
  static const BATTLE_RATING_ME = '/battle/rating/me/';
  static const BATTLE_LEADERBOARD = '/battle/leaderboard/';
  static const BATTLE_HISTORY = '/battle/history/';
  static const BATTLE_ELO_HISTORY = '/battle/elo-history/';
  static const BATTLE_GRADE_STATS = '/battle/grade-stats/';
}

class DatabaseKeys {
  static const CATEGORY_LIST = 'category_list/';
  static const GUID_LIST = 'guid_list/';
  static const ARTICLE = 'article/';
  static const PRODUCT_LIST = 'product_list/';
}

class AnalyticsEventName {
  static const RESTAURANT = 'restaurant';
  static const BANNER = 'banner';
}

class AnalyticsParameter {
  static const String onClick = 'on_click';
  static const String onPhoneClick = 'on_phone_click';
  static const String onMapClick = 'on_map_click';
  static const String onMenuClick = 'on_menu_click';
  static const String onSocialClick = 'on_social_click';
}
