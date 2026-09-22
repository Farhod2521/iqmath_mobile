import 'package:flutter/material.dart';
import 'package:my_flutter_template/features/auth/domain/usecases/confirm_usecase.dart';
import 'package:my_flutter_template/features/auth/domain/usecases/login_usecase.dart';
import 'package:my_flutter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_flutter_template/features/auth/presentation/pages/reset_code_number_page.dart';
import 'package:my_flutter_template/features/auth/presentation/pages/reset_password_page.dart';
import 'package:my_flutter_template/features/battle/presentation/page_args/battle_room_page_args.dart';
import 'package:my_flutter_template/features/battle/presentation/pages/battle_history_page.dart';
import 'package:my_flutter_template/features/battle/presentation/pages/battle_landing_page.dart';
import 'package:my_flutter_template/features/battle/presentation/pages/battle_leaderboard_page.dart';
import 'package:my_flutter_template/features/battle/presentation/pages/battle_room_page.dart';
import 'package:my_flutter_template/features/home/domain/usecases/get_products_usecase.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home/home_page.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home/widgets/calculator_page.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home/widgets/multiplication_table.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/parent_assimilation_page.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_teacher/home_teacher_page.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_teacher/payment_panel_page.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_teacher/referal_link_page.dart';
import 'package:my_flutter_template/features/home/presentation/pages/notification/notification_page.dart';
import 'package:my_flutter_template/features/home/presentation/pages/settings/settings_page.dart';
import 'package:my_flutter_template/features/main/domain/usecases/get_user_info_usecase.dart';
import 'package:my_flutter_template/features/main/presentation/pages/main_page.dart';
import 'package:my_flutter_template/features/main_parent/presentation/pages/main_parent_page.dart';
import 'package:my_flutter_template/features/main_teacher/presentation/pages/main_teacher_page.dart';
import 'package:my_flutter_template/features/parent_subject/presentation/pages/parent_student_diagnostics_page.dart';
import 'package:my_flutter_template/features/parent_subject/presentation/pages/parent_subject_page.dart';
import 'package:my_flutter_template/features/profile/domain/usecases/get_faq_usecase.dart';
import 'package:my_flutter_template/features/profile/presentation/blocs/security/security_bloc.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/ball_coins_page.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/balls_page.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/change_password_page.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/chat_page.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/coupons_page.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/diagnostic_history_page.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/profile_page.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/security_page.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/blocs/screen_lock_bloc.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/pages/screen_lock_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/features/subject/presentation/bloc/subject_bloc/subject_bloc.dart';
import 'package:my_flutter_template/features/suggestion/presentation/pages/suggestion_page.dart';

import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/presentation/page_args/auth_args.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/auth/presentation/pages/otp_code_page.dart';
import '../features/diagnostics/presentation/pages/diagnostics_page.dart';
import '../features/home/presentation/blocs/home/home_bloc.dart';
import '../features/home/presentation/blocs/notification/notification_bloc.dart';
import '../features/home/presentation/pages/home_parent/home_parent_page.dart';
import '../features/home/presentation/pages/home_parent/widget/parent_information_screen.dart';
import '../features/main/presentation/bloc/main_bloc.dart';
import '../features/products/presentation/pages/products_page.dart';
import '../features/profile/domain/usecases/delete_user_usecase.dart';
import '../features/profile/domain/usecases/update_user_info_usecase.dart';
import '../features/profile/domain/usecases/upload_image_usecase.dart';
import '../features/profile/presentation/arguments/edit_profile_page_args.dart';
import '../features/profile/presentation/blocs/edit_profile/edit_profile_bloc.dart';
import '../features/profile/presentation/blocs/faq/faq_bloc.dart';
import '../features/profile/presentation/blocs/profile/profile_bloc.dart';
import '../features/profile/presentation/pages/coupon_users_page.dart';
import '../features/profile/presentation/pages/faq_page.dart';
import '../features/screen_lock/presentation/page_args/screen_lock_args.dart';
import '../features/splash/presentation/bloc/splash_bloc.dart';
import '../features/splash/presentation/pages/onboarding_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/subject/domain/usecases/get_subject_usecase.dart';
import '../features/subject/presentation/pages/question_page.dart';
import '../features/subject/presentation/pages/subject_detail_page.dart';
import '../features/subject/presentation/pages/subject_page.dart';
import '../features/subject/presentation/pages/telegram_bot_page.dart';
import '../features/subject/presentation/widget/book_card_widget.dart';
import '../features/subject/presentation/widget/topic_card.dart';
import '../injector_container.dart';
import 'name_routes.dart';

typedef OnGenerateRoute = Route<dynamic>? Function(RouteSettings settings);

final rootNavigatorKey = GlobalKey<NavigatorState>();
final mainRootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();

class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        // Routes.splash => CupertinoPageRoute(
        //     settings: settings,
        //     builder: (_) => BlocProvider(
        //       create: (context) => SplashBloc(),
        //       child: const SplashPage(),
        //     ),
        //   ),
        Routes.onBoarding => PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => const OnboardingPage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            // transitionDuration: const Duration(milliseconds: 50),
          ),
        Routes.auth => PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => BlocProvider(
              create: (context) => AuthBloc(
                confirmUseCase: sl<ConfirmUseCase>(),
                loginUseCase: sl<LoginUseCase>(),
                registerUseCase: sl<RegisterUseCase>(),
              ),
              child: AuthPage(
                args: settings.arguments as AuthPageArgs?,
              ),
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            // transitionDuration: const Duration(milliseconds: 50),
            // builder: (_) => BlocProvider(
            //   create: (context) => AuthBloc(
            //     confirmUseCase: sl<ConfirmUseCase>(),
            //     loginUseCase: sl<LoginUseCase>(),
            //     registerUseCase: sl<RegisterUseCase>(),
            //   ),
            //   child: AuthPage(
            //       // args: settings.arguments as AuthPageArgs,
            //       ),
            // ),
          ),
        Routes.otp => CupertinoPageRoute(
            settings: settings,
            builder: (_) => BlocProvider(
              create: (context) => AuthBloc(
                confirmUseCase: sl<ConfirmUseCase>(),
                loginUseCase: sl<LoginUseCase>(),
                registerUseCase: sl<RegisterUseCase>(),
              ),
              child: OTPVerificationPage(
                args: settings.arguments as OtpPageArgs,
              ),
            ),
          ),
        Routes.resetCode => CupertinoPageRoute(
            settings: settings,
            builder: (_) => ResetCodeNumberPage(),
          ),
        Routes.resetPassword => CupertinoPageRoute(
            settings: settings,
            builder: (_) => ResetPasswordPage(
              phoneNumber: settings.arguments as String,
            ),
          ),
        Routes.screenLock => PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => BlocProvider(
              create: (context) => ScreenLockBloc(),
              child: ScreenLockPage(
                args: settings.arguments as ScreenLockPageArgs?,
              ),
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            // transitionDuration: const Duration(milliseconds: 50),
            // builder: (_) => BlocProvider(
            //   create: (context) => ScreenLockBloc(),
            //   child: ScreenLockPage(
            //     args: settings.arguments as ScreenLockPageArgs,
            //   ),
            // ),
          ),
        Routes.screenLockClone => MaterialPageRoute(
            settings: settings,
            builder: (context) => BlocProvider(
              create: (context) => ScreenLockBloc(),
              child: ScreenLockPage(
                args: settings.arguments as ScreenLockPageArgs?,
              ),
            ),
          ),
        Routes.changePassword => CupertinoPageRoute(
            settings: settings,
            builder: (context) => ChangePasswordPage(),
          ),
        // Routes.qrCodeScan => PageRouteBuilder(
        //     pageBuilder: (context, animation, secondaryAnimation) =>
        //         SlideTransition(
        //       position: Tween<Offset>(
        //         begin: const Offset(0, 1),
        //         end: Offset.zero,
        //       ).animate(animation),
        //       child: BlocProvider(
        //         create: (context) => QrCodeBloc(
        //           scanQrCodeUseCase: sl<ScanQrCodeUseCase>(),
        //         ),
        //         child: QrCodeScanPage(
        //           args: settings.arguments as QrCodePageArgs,
        //         ),
        //       ),
        //     ),
        //   ),
        Routes.main => CupertinoPageRoute(
            settings: settings,
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => MainBloc(sl<GetUserInfoUseCase>()),
                ),
                BlocProvider(
                  create: (context) => SubjectBloc(
                    getSubjectUseCase: sl<GetSubjectUseCase>(),
                  ),
                ),
                BlocProvider(
                  create: (context) =>
                      HomeBloc(getProductsUseCase: sl<GetProductsUseCase>()),
                ),
              ],
              child: MainPage(
                key: mainRootNavigatorKey,
                onGenerateRoutes: const [
                  HomeRoutes.onGenerateRoute,
                  SubjectRoutes.onGenerateRoute,
                  Diagnostics.onGenerateRoute,
                  Suggestions.onGenerateRoute,
                  ProfileRoutes.onGenerateRoute,
                ],
              ),
            ),
          ),
        Routes.mainParent => CupertinoPageRoute(
            settings: settings,
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => MainBloc(sl<GetUserInfoUseCase>()),
                ),
                BlocProvider(
                  create: (context) =>
                      HomeBloc(getProductsUseCase: sl<GetProductsUseCase>()),
                ),
              ],
              child: MainParentPage(
                key: mainRootNavigatorKey,
                onGenerateRoutes: const [
                  HomeParentRoutes.onGenerateRoute,
                  ParentSubjectsResults.onGenerateRoute,
                ],
              ),
            ),
          ),
        Routes.mainTeacher => CupertinoPageRoute(
            settings: settings,
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => MainBloc(sl<GetUserInfoUseCase>()),
                ),
                BlocProvider(
                  create: (context) =>
                      HomeBloc(getProductsUseCase: sl<GetProductsUseCase>()),
                ),
              ],
              child: MainTeacherPage(
                key: mainRootNavigatorKey,
                onGenerateRoutes: const [
                  HomeTeacherRoutes.onGenerateRoute,
                  // ParentSubjectsResults.onGenerateRoute,
                ],
              ),
            ),
          ),
        Routes.notification => CupertinoPageRoute(
            settings: settings,
            builder: (_) => BlocProvider(
              create: (context) => NotificationBloc(),
              child: const NotificationPage(),
            ),
          ),
        Routes.editProfile => CupertinoPageRoute(
            settings: settings,
            builder: (_) => BlocProvider(
              create: (context) => EditProfileBloc(
                updateUserInfoUseCase: sl<UpdateUserInfoUseCase>(),
                uploadImageUseCase: sl<UploadImageUseCase>(),
              ),
              child: EditProfilePage(
                args: settings.arguments as EditProfilePageArgs,
              ),
            ),
          ),
        Routes.faq => CupertinoPageRoute(
            settings: settings,
            builder: (_) => BlocProvider(
              create: (context) => FaqBloc(sl<GetFaqUseCase>()),
              child: const FAQPage(),
            ),
          ),
        Routes.security => CupertinoPageRoute(
            settings: settings,
            builder: (_) => BlocProvider(
              create: (context) => SecurityBloc(
                deleteUserUseCase: sl<DeleteUserUseCase>(),
              ),
              child: const SecurityPage(),
            ),
          ),
        Routes.subjectDetail => CupertinoPageRoute(
            settings: settings,
            builder: (_) => SubjectDetailPage(
              args: settings.arguments as SubjectDetailArguments,
            ),
          ),
        Routes.questions => CupertinoPageRoute(
            settings: settings,
            builder: (_) => QuestionPage(
              arguments: settings.arguments as QuestionPageArguments,
            ),
          ),
        Routes.products => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const ProductsPage(),
          ),
        Routes.settings => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const SettingsPage(),
          ),
        Routes.diagnosticHistory => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const DiagnosticHistoryPage(),
          ),
        Routes.telegramBot => CupertinoPageRoute(
            settings: settings,
            builder: (_) => TelegramBotPage(),
          ),
        Routes.chat => CupertinoPageRoute(
            settings: settings,
            builder: (_) => ChatPage(),
          ),
        Routes.ballCoins => CupertinoPageRoute(
            settings: settings,
            builder: (_) => BallCoinsPage(),
          ),
        Routes.balls => CupertinoPageRoute(
            settings: settings,
            builder: (_) => BallsPage(),
          ),
        Routes.couponUsers => CupertinoPageRoute(
            settings: settings,
            builder: (_) => CouponUsersPage(),
          ),
        Routes.coupons => CupertinoPageRoute(
            settings: settings,
            builder: (_) => CouponsPage(),
          ),
        Routes.referalLink => CupertinoPageRoute(
            settings: settings,
            builder: (_) => ReferalLinkPage(),
          ),
        Routes.paymentPanel => CupertinoPageRoute(
            settings: settings,
            builder: (_) => PaymentPanelPage(),
          ),
        Routes.parentInfo => CupertinoPageRoute(
            settings: settings,
            builder: (_) => ParentInformationScreen(
              args: settings.arguments as ParentInformationScreenArgs,
            ),
          ),
        Routes.parentAssimilation => CupertinoPageRoute(
            settings: settings,
            builder: (_) => ParentAssimilationPage(
              args: settings.arguments as ParentAssimilationScreenArgs,
            ),
          ),
        Routes.multiplicationTable => CupertinoPageRoute(
            settings: settings,
            builder: (_) => KarraSwipeScreen(),
          ),
        Routes.calculator => CupertinoPageRoute(
            settings: settings,
            builder: (_) => CalculatorPage(),
          ),
        Routes.battle => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const BattleLandingPage(),
          ),
        Routes.battleRoom => CupertinoPageRoute(
            settings: settings,
            builder: (_) => BattleRoomPage(
              args: settings.arguments as BattleRoomPageArgs,
            ),
          ),
        Routes.battleHistory => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const BattleHistoryPage(),
          ),
        Routes.battleLeaderboard => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const BattleLeaderboardPage(),
          ),
        _ => null,
      };
}

class SubjectRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        Routes.subject => CupertinoPageRoute(
            settings: settings,
            builder: (_) => SubjectPage(),
          ),
        Routes.subjectDetail => CupertinoPageRoute(
            settings: settings,
            builder: (_) => SubjectDetailPage(
              args: settings.arguments as SubjectDetailArguments,
            ),
          ),
        Routes.questions => CupertinoPageRoute(
            settings: settings,
            builder: (_) => QuestionPage(
              arguments: settings.arguments as QuestionPageArguments,
            ),
          ),
        _ => null,
      };
}

class HomeRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        Routes.home => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const HomePage(),
          ),
        _ => null,
      };
}

class HomeParentRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        Routes.home => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const HomeParentPage(),
          ),
        _ => null,
      };
}

class HomeTeacherRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        Routes.home => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const HomeTeacherPage(),
          ),
        _ => null,
      };
}

class Diagnostics {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        Routes.diagnostics => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const DiagnosticsPage(),
          ),
        _ => null,
      };
}

class Suggestions {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        Routes.suggestions => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const SuggestionPage(),
          ),
        _ => null,
      };
}

class Products {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        Routes.products => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const ProductsPage(),
          ),
        _ => null,
      };
}

class ProfileRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        Routes.profile => CupertinoPageRoute(
            settings: settings,
            builder: (_) => BlocProvider(
              create: (context) => ProfileBloc(),
              child: const ProfilePage(),
            ),
          ),
        Routes.products => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const ProductsPage(),
          ),
        Routes.diagnosticHistory => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const DiagnosticHistoryPage(),
          ),
        _ => null,
      };
}

class ParentSubjectsResults {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      switch (settings.name) {
        Routes.parentSubject => CupertinoPageRoute(
            settings: settings,
            builder: (_) => const ParentSubjectPage(),
          ),
        Routes.parentStudentsDiagnostics => CupertinoPageRoute(
            settings: settings,
            builder: (_) => ParentStudentDiagnosticsPage(
              studentId: settings.arguments as String,
            ),
          ),
        _ => null,
      };
}
