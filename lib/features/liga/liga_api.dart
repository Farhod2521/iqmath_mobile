import 'package:dio/dio.dart';

import '../../constants/constants.dart';
import '../../core/widgets/dash_ui.dart';
import '../../injector_container.dart';

/// Matematik Liga — saytdagi bilan bir xil API (/api/v1/liga/...).
class LigaApi {
  LigaApi._();

  static Dio get _dio => sl<Dio>();
  static const _base = '${Constants.baseUrl}/liga';

  /// Mavsum, o'quvchi sinfining testlari, sinf reytingi, g'oliblar
  static Future<Map<String, dynamic>> current() async => asMap((await _dio.get('$_base/current/')).data);

  /// Yopilgan mavsumlar g'oliblari
  static Future<List<Map<String, dynamic>>> winnersHistory() async =>
      asMapList((await _dio.get('$_base/winners/')).data);

  /// Mavsumlar ro'yxati + sinflar (filtr uchun) + o'quvchining sinfi
  static Future<Map<String, dynamic>> seasons() async => asMap((await _dio.get('$_base/seasons/')).data);

  /// Mavsum natijalari: sinf g'oliblari va haftalik test g'oliblari
  static Future<Map<String, dynamic>> seasonResults(int seasonId, int? gradeId) async => asMap((await _dio.get(
        '$_base/seasons/$seasonId/results/',
        queryParameters: {if (gradeId != null) 'grade': gradeId},
      ))
          .data);

  /// O'quvchining liga tarixi (mavsumlar bo'yicha ball, o'rin, testlar)
  static Future<Map<String, dynamic>> myHistory() async => asMap((await _dio.get('$_base/my-history/')).data);

  /// Ball tarixi (sahifalab): {count, next, results}
  static Future<Map<String, dynamic>> myPoints({int page = 1, String? source}) async => asMap((await _dio.get(
        '$_base/my-points/',
        queryParameters: {'page': page, 'page_size': 20, if (source != null) 'source': source},
      ))
          .data);

  /// Ligaga qo'shilish: tanlangan sinf va qoidalarga rozilik
  /// Sinflar ro'yxati (liga javobida `grades` bo'lmasa — eski backend uchun zaxira)
  static Future<List<Map<String, dynamic>>> classes() async {
    final list = asMapList((await _dio.get('${Constants.baseUrl}/auth/class/class_name_listview/')).data);
    int order(Map m) => int.tryParse(RegExp(r'\d+').stringMatch('${m['name']}') ?? '') ?? 999;
    list.sort((a, b) => order(a).compareTo(order(b)));
    return list;
  }

  static Future<void> join(int seasonId, int gradeId) =>
      _dio.post('$_base/seasons/$seasonId/join/', data: {'grade': gradeId, 'accept_rules': true});

  /// Testni boshlaydi (yoki boshlangan urinishni qaytaradi)
  static Future<Map<String, dynamic>> start(int testId) async =>
      asMap((await _dio.post('$_base/tests/$testId/start/')).data);

  static Future<Map<String, dynamic>> attempt(int attemptId) async =>
      asMap((await _dio.get('$_base/attempts/$attemptId/')).data);

  static Future<void> answer(int attemptId, int questionId, {int? choice, String? textAnswer}) =>
      _dio.post('$_base/attempts/$attemptId/answer/', data: {
        'question': questionId,
        if (choice != null) 'choice': choice,
        if (textAnswer != null) 'text_answer': textAnswer,
      });

  static Future<Map<String, dynamic>> finish(int attemptId) async =>
      asMap((await _dio.post('$_base/attempts/$attemptId/finish/')).data);

  /// Backend xabari (message / detail) yoki null
  static String? errorText(Object e) {
    if (e is DioException && e.response?.data is Map) {
      final body = e.response!.data as Map;
      final text = '${body['message'] ?? body['detail'] ?? ''}'.trim();
      return text.isEmpty ? null : text;
    }
    return null;
  }

  static int? statusCode(Object e) => e is DioException ? e.response?.statusCode : null;
}
