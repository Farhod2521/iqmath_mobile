import 'dart:async';
import 'dart:io';
import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_flutter_template/features/battle/data/data_source/remote/battle_remote_data_source.dart';
import 'package:my_flutter_template/features/battle/data/data_source/remote/battle_remote_data_source_impl.dart';
import 'package:my_flutter_template/features/battle/data/data_source/socket/battle_socket_service.dart';
import 'package:my_flutter_template/features/battle/data/repository/battle_repository_impl.dart';
import 'package:my_flutter_template/features/battle/domain/repository/battle_repository.dart';
import 'package:my_flutter_template/features/battle/domain/usecases/battle_usecases.dart';
import 'package:my_flutter_template/features/home/data/data_source/local/home_local_data_source.dart';
import 'package:my_flutter_template/features/home/data/data_source/local/home_local_data_source_impl.dart';
import 'package:my_flutter_template/features/home/domain/usecases/get_products_usecase.dart';
import 'package:my_flutter_template/router/name_routes.dart';
import 'package:my_flutter_template/services/analytics_service.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/platform/network_info.dart';
import 'package:my_flutter_template/features/auth/data/data_source/local/auth_local_data_source_impl.dart';
import 'package:my_flutter_template/features/auth/data/data_source/remote/auth_remote_data_source_impl.dart';
import 'package:my_flutter_template/features/auth/data/repository/auth_repository_impl.dart';
import 'package:my_flutter_template/features/auth/domain/usecases/confirm_usecase.dart';
import 'package:my_flutter_template/features/auth/domain/usecases/login_usecase.dart';
import 'package:my_flutter_template/features/auth/domain/usecases/register_usecase.dart';
import 'package:my_flutter_template/features/home/data/data_source/remote/home_remote_data_source_impl.dart';
import 'package:my_flutter_template/features/home_dashboard/data/data_source/remote/home_dashboard_remote_data_source.dart';
import 'package:my_flutter_template/features/home_dashboard/data/data_source/remote/home_dashboard_remote_data_source_impl.dart';
import 'package:my_flutter_template/features/home_dashboard/data/repository/home_dashboard_repository_impl.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/repository/home_dashboard_repository.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_home_dashboard_usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_my_score_usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_rating_usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_study_stats_usecase.dart';
import 'package:my_flutter_template/features/main/data/data_source/remote/main_remote_data_source_impl.dart';
import 'package:my_flutter_template/features/main/data/repository/main_repository_impl.dart';
import 'package:my_flutter_template/features/main/domain/usecases/get_user_info_usecase.dart';
import 'package:my_flutter_template/features/profile/data/data_source/remote/profile_remote_data_source_impl.dart';
import 'package:my_flutter_template/features/profile/data/repository/profile_repository_impl.dart';
import 'package:my_flutter_template/features/profile/domain/usecases/get_faq_usecase.dart';
import 'package:my_flutter_template/features/profile/domain/usecases/upload_image_usecase.dart';
import 'package:my_flutter_template/features/search/data/data_source/remote/search_remote_data_source.dart';
import 'package:my_flutter_template/features/search/domain/repository/search_repository.dart';
import 'package:my_flutter_template/features/search/domain/usecases/get_search_restaurants.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:my_flutter_template/services/geolocator_service.dart';
import 'package:my_flutter_template/services/local_auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';

import 'core/app_bloc/bloc_observer.dart';
import 'core/device/device_identity.dart';
import 'features/auth/data/data_source/local/auth_local_data_source.dart';
import 'features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/presentation/page_args/auth_args.dart';
import 'features/home/data/data_source/remote/home_remote_data_source.dart';
import 'features/home/data/repository/home_repository_impl.dart';
import 'features/home/domain/repository/home_repository.dart';
import 'features/main/data/data_source/remote/main_remote_data_source.dart';
import 'features/main/domain/repository/main_repository.dart';
import 'features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'features/profile/domain/repository/profile_repository.dart';
import 'features/profile/domain/usecases/delete_user_usecase.dart';
import 'features/profile/domain/usecases/update_user_info_usecase.dart';
import 'features/search/data/data_source/remote/search_remote_data_source_impl.dart';
import 'features/search/data/repository/search_repository_impl.dart';
import 'features/subject/data/data_source/remote/subject_remote_data_source.dart';
import 'features/subject/data/data_source/remote/subject_remote_data_source_impl.dart';
import 'features/subject/data/repository/subject_repository_impl.dart';
import 'features/subject/domain/repository/subject_repository.dart';
import 'features/subject/domain/usecases/get_subject_usecase.dart';

final sl = GetIt.instance;
late Box<dynamic> _box;
Chuck alice = Chuck(navigatorKey: rootNavigatorKey, showNotification: true);

Future<void> init() async {
  //External
  await initHive();
  // Qurilma nomi / User-Agent (2 ta qurilma cheklovi uchun) — fonda aniqlanadi
  unawaited(DeviceIdentity.init());
  sl.registerLazySingleton(
    () {
      final dio = Dio();
      bool isRefreshing = false;
      List<Function> requestsQueue = [];

      dio.interceptors.addAll([
        InterceptorsWrapper(
          onRequest: (request, handler) {
            var token = sl<LocalSource>().getAccessToken();
            request.headers.addAll({
              "Authorization": token,
              // Backend qurilmani shu identifikator bo'yicha taniydi
              "X-Device-Id": DeviceIdentity.deviceId(sl<LocalSource>()),
              "X-version": Platform.isIOS
                  ? "ios-${sl<LocalSource>().getAppVersion()?.split(',').firstOrNull ?? ''}"
                  : "android-${sl<LocalSource>().getAppVersion()?.split(',').firstOrNull ?? ''}",
            });
            handler.next(request);
          },
          onError: (error, handler) async {
            if (error.response?.statusCode == 410) {
              sl<LocalSource>().setForceUpdate(true);
              handler.next(error);
              return;
            }

            if (error.response?.statusCode == 401) {
              // Qurilma boshqa qurilmadan chiqarib yuborilgan — tokenni
              // yangilab bo'lmaydi, darhol login sahifasiga qaytamiz
              if (_isDeviceRevoked(error.response?.data)) {
                await _logoutUser(deviceRevoked: true);
                handler.next(error);
                return;
              }

              // Agar refresh token endpoint bo'lsa, to'g'ridan logout qil
              if (error.requestOptions.path.contains('/auth/token/refresh/')) {
                await _logoutUser();
                handler.next(error);
                return;
              }

              // Agar allaqachon refresh qilinayotgan bo'lsa, navbatga qo'sh
              if (isRefreshing) {
                requestsQueue.add(() async {
                  try {
                    final opts = Options(
                      method: error.requestOptions.method,
                      headers: error.requestOptions.headers,
                    );
                    opts.headers!['Authorization'] =
                        sl<LocalSource>().getAccessToken();

                    final cloneReq = await dio.request(
                      error.requestOptions.path,
                      options: opts,
                      data: error.requestOptions.data,
                      queryParameters: error.requestOptions.queryParameters,
                    );
                    handler.resolve(cloneReq);
                  } catch (e) {
                    handler.next(error);
                  }
                });
                return;
              }

              isRefreshing = true;

              try {
                String? refreshToken = sl<LocalSource>().getRefreshToken();

                if (refreshToken == null || refreshToken.isEmpty) {
                  isRefreshing = false;
                  await _logoutUser();
                  handler.next(error);
                  return;
                }

                // Alohida Dio instance ishlatamiz (interceptorsiz)
                final refreshDio = Dio(BaseOptions(
                  baseUrl: 'https://api.iqmath.uz',
                  validateStatus: (status) => status! < 500,
                ));

                final response = await refreshDio.post(
                  '/api/v1/auth/token/refresh/',
                  data: {"refresh": refreshToken},
                );
                debugPrint('refreshToken: $response');
                if (response.statusCode == 200 &&
                    response.data['access'] != null) {
                  String newAccessToken = response.data['access'];
                  sl<LocalSource>().setAccessToken('Bearer $newAccessToken');

                  // Asl so'rovni qayta yubor
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  );
                  opts.headers!['Authorization'] = newAccessToken;

                  final cloneReq = await dio.request(
                    error.requestOptions.path,
                    options: opts,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  );

                  // Navbatdagi barcha so'rovlarni bajar
                  for (var request in requestsQueue) {
                    await request();
                  }
                  requestsQueue.clear();

                  isRefreshing = false;
                  handler.resolve(cloneReq);
                } else {
                  isRefreshing = false;
                  requestsQueue.clear();
                  await _logoutUser(
                      deviceRevoked: _isDeviceRevoked(response.data));
                  handler.next(error);
                }
              } catch (e) {
                isRefreshing = false;
                requestsQueue.clear();
                await _logoutUser();
                handler.next(error);
              }
            } else {
              handler.next(error);
            }
          },
        ),
        if (kDebugMode)
          LogInterceptor(
            request: true,
            responseBody: true,
            error: true,
            requestBody: true,
          ),
        if (kDebugMode) alice.dioInterceptor,
      ]);

      return dio;
    },
  );
  sl.registerLazySingleton(() => GeoLocatorService());
  // sl.registerSingletonAsync<NotificationService>(
  //   () async {
  //     final service = NotificationService();
  //     await service.init();
  //     return service;
  //   },
  // );
  sl.registerSingletonAsync<AnalyticsService>(
    () async {
      final service = AnalyticsService();
      await service.init();
      return service;
    },
  );
  Bloc.observer = AppBlocObserver();
  sl.registerSingleton<LocalAuthService>(
      LocalAuthService(LocalAuthentication())..init());
  // sl.registerLazySingleton(() => InternetConnectionCheckerPlus());
  //Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(
      // sl()
      ));
  sl.registerSingleton<LocalSource>(LocalSource(_box));
  sl.registerSingleton<AppBloc>(AppBloc(
      // sl()
      ));
  // Features
  mainFeature();
  authFeature();
  homeFeature();
  homeDashboardFeature();
  subjectFeature();
  searchFeature();
  profileFeature();
  battleFeature();
}

/// 401 javobi qurilma "Qurilmalar" bo'limidan chiqarib yuborilgani sababli
/// kelganmi (backend: authentication.py / token_refresh.py).
bool _isDeviceRevoked(dynamic body) {
  if (body is! Map) return false;
  if (body['code'] == 'device_revoked') return true;
  final detail = body['detail']?.toString() ?? '';
  return detail.contains('chiqarib yuborilgan');
}

Future<void> _logoutUser({bool deviceRevoked = false}) async {
  String phoneNumber = sl<LocalSource>().getPhoneNumber() ?? '';
  String password = sl<LocalSource>().getUserPassword() ?? '';
  String pinCode = sl<LocalSource>().getPinCode() ?? '';

  await sl<LocalSource>().clear();

  sl<LocalSource>().setPhoneNumber(phoneNumber);
  sl<LocalSource>().setUserPassword(password);
  sl<LocalSource>().setPinCode(pinCode);
  if (deviceRevoked) sl<LocalSource>().setDeviceRevoked(true);

  Future.microtask(() {
    if (rootNavigatorKey.currentContext != null) {
      Navigator.of(rootNavigatorKey.currentContext!).pushNamedAndRemoveUntil(
        Routes.auth,
        (route) => false,
        arguments: AuthPageArgs(),
      );
    }
  });
}

void mainFeature() {
  sl.registerLazySingleton(() => GetUserInfoUseCase(sl()));
  sl.registerLazySingleton<MainRepository>(() => MainRepositoryImpl(sl()));
  sl.registerLazySingleton<MainRemoteDataSource>(
      () => MainRemoteDataSourceImpl(sl()));
}

void profileFeature() {
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserInfoUseCase(sl()));
  sl.registerLazySingleton(() => GetFaqUseCase(sl()));
  sl.registerLazySingleton(() => UploadImageUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl()));
}

void authFeature() {
  ///Usecases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmUseCase(sl()));

  ///Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      authLocalDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  ///Data and Network
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      sl(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      _box,
    ),
  );
}

void homeFeature() {
  //Usecases

  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl()),
  );

  //Repositories
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      homeLocalDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  //Data and Network
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(_box));
}

void homeDashboardFeature() {
  //Usecases
  sl.registerLazySingleton(() => GetHomeDashboardUseCase(sl()));
  sl.registerLazySingleton(() => GetMyScoreUseCase(sl()));
  sl.registerLazySingleton(() => GetRatingUseCase(sl()));
  sl.registerLazySingleton(() => GetStudyStatsUseCase(sl()));

  //Repositories
  sl.registerLazySingleton<HomeDashboardRepository>(
    () => HomeDashboardRepositoryImpl(remoteDataSource: sl()),
  );

  //Data and Network
  sl.registerLazySingleton<HomeDashboardRemoteDataSource>(
    () => HomeDashboardRemoteDataSourceImpl(dio: sl()),
  );
}

void battleFeature() {
  //Usecases
  sl.registerLazySingleton(() => GetBattleSubjectsUseCase(sl()));
  sl.registerLazySingleton(() => GetBattleGradeStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetBattleRatingUseCase(sl()));
  sl.registerLazySingleton(() => CreateBattleRoomUseCase(sl()));
  sl.registerLazySingleton(() => JoinBattleRoomUseCase(sl()));
  sl.registerLazySingleton(() => GetBattleHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetBattleEloHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetBattleLeaderboardUseCase(sl()));

  //Repositories
  sl.registerLazySingleton<BattleRepository>(
    () => BattleRepositoryImpl(remoteDataSource: sl()),
  );

  //Data and Network
  sl.registerLazySingleton<BattleRemoteDataSource>(
    () => BattleRemoteDataSourceImpl(dio: sl()),
  );

  // Har bir battle xonasi uchun yangi socket instance kerak — shu sababli
  // singleton emas, `registerFactory` ishlatiladi.
  sl.registerFactory<BattleSocketService>(() => BattleSocketService());
}

void subjectFeature() {
  //Usecases

  sl.registerLazySingleton<GetSubjectUseCase>(
    () => GetSubjectUseCase(sl()),
  );

  //Repositories
  sl.registerLazySingleton<SubjectRepository>(
    () => SubjectRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  //Data and Network
  sl.registerLazySingleton<SubjectRemoteDataSource>(
    () => SubjectRemoteDataSourceImpl(
      dio: sl(),
      networkInfo: sl(),
    ),
  );
}

void searchFeature() {
  //Usecases
  sl.registerLazySingleton<GetSearchRestaurants>(
      () => GetSearchRestaurants(sl()));
  //Repositories
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl()));

  //Data and Network
  sl.registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSourceImpl(sl()));
}

Future<void> initHive() async {
  const boxName = 'iq_math_mobile_box';
  Directory directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  _box = await Hive.openBox<dynamic>(boxName);
}
