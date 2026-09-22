import 'package:my_flutter_template/features/auth/presentation/page_args/auth_page_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../../../injector_container.dart';
import '../../../../router/name_routes.dart';
import '../bloc/auth_bloc.dart';
import '../mixins/auth_page_mixin.dart';
import '../page_args/auth_args.dart';

/// Auth sahifa dizayni uchun ranglar
const Color _kPrimary = Color(0xFF2563EB);
const Color _kPrimaryDark = Color(0xFF1D4ED8);
const Color _kPrimaryLight = Color(0xFF3B82F6);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF64748B);
const Color _kFieldFill = Color(0xFFFAFCFF);
const Color _kBorder = Color(0xFFE4ECFA);
const Color _kScaffold = Color(0xFFF1F6FE);
const Color _kSoftBlue = Color(0xFFF2F7FF);
const Color _kError = Color(0xFFDC3545);

class AuthPage extends StatefulWidget {
  final AuthPageArgs? args;

  const AuthPage({
    super.key,
    required this.args,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with AuthPageMixin {
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;
  late final TextEditingController fullNameController;

  final textInputFormatter = MaskTextInputFormatter(
    mask: "(##) ###-##-##",
    filter: {"#": RegExp(r'[0-9]')},
  );

  String selectedAuthType = 'login';
  String? selectedRole;
  int? selectedGrade;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _phoneError;
  String? _passwordError;
  String? _nameError;

  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();

  List<String> getRoles(String locale) {
    return [
      AuthPageLocalization.get('student', locale),
      AuthPageLocalization.get('teacher', locale),
      AuthPageLocalization.get('parent', locale),
    ];
  }

  final List<int> grades = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  @override
  void initState() {
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    fullNameController = TextEditingController();
    setPhonePassword();
    super.initState();

    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        _validatePhone();
      }
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        _validatePassword();
      }
      setState(() {});
    });
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        _validateName();
      }
      setState(() {});
    });
  }

  Future<void> setPhonePassword() async {
    final localSource = sl<LocalSource>();
    phoneController.text = localSource.getPhoneNumber() ?? '';
    passwordController.text = localSource.getUserPassword() ?? '';
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
    setState(() {
      if (phoneController.text.isEmpty) {
        _phoneError = AuthPageLocalization.get('phoneError', locale);
      } else if (phoneController.text.length < 14) {
        _phoneError = AuthPageLocalization.get('phoneIncomplete', locale);
      } else {
        _phoneError = null;
      }
    });
  }

  void _validatePassword() {
    final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
    setState(() {
      if (passwordController.text.isEmpty) {
        _passwordError = AuthPageLocalization.get('passwordError', locale);
      } else if (passwordController.text.length < 4) {
        _passwordError = AuthPageLocalization.get('passwordShort', locale);
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateName() {
    final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
    setState(() {
      if (fullNameController.text.isEmpty) {
        _nameError = AuthPageLocalization.get('nameError', locale);
      } else {
        _nameError = null;
      }
    });
  }

  void _handleSubmit() {
    FocusScope.of(context).unfocus();
    if (selectedAuthType == 'login') {
      context.read<AuthBloc>().add(
            AuthLoginEvent(
              phoneNumber: phoneController.text,
              password: passwordController.text,
            ),
          );
    } else {
      if (getRoleKey(selectedRole ?? '') == 'tutor') {
        TopNotification.showError(
          context,
          message: AuthPageLocalization.get(
              'roleError', context.read<AppBloc>().state.appLocale ?? 'uz'),
        );
      } else {
        context.read<AuthBloc>().add(
              AuthRegisterEvent(
                fullName: fullNameController.text,
                phone: phoneController.text,
                role: getRoleKey(selectedRole ?? ''),
                className: selectedGrade.toString(),
                referralCode: passwordController.text,
                lang: (context.read<AppBloc>().state.appLocale != 'en'
                        ? context.read<AppBloc>().state.appLocale
                        : 'uz') ??
                    'uz',
              ),
            );
      }
    }
  }

  String getRoleKey(String role) {
    if (role == 'O\'qituvchi' || role == 'Учитель') return 'tutor';
    if (role == 'Ota-ona' || role == 'Родитель') return 'parent';
    if (role == 'O\'quvchi' || role == 'Ученик') return 'student';
    return '';
  }

  bool _canProceed() {
    if (selectedAuthType == 'login') {
      return phoneController.text.length >= 14 &&
          passwordController.text.length >= 4;
    } else {
      bool basicValidation = fullNameController.text.isNotEmpty &&
          phoneController.text.length >= 14 &&
          selectedRole != null;

      final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
      final studentText = AuthPageLocalization.get('student', locale);

      if (selectedRole == studentText) {
        return basicValidation && selectedGrade != null;
      }

      return basicValidation;
    }
  }

  void _showRoleBottomSheet(String locale) {
    final roles = getRoles(locale);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(20),
              Text(
                AuthPageLocalization.get('selectRole', locale),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _kInk,
                ),
              ),
              const Gap(16),
              ...roles.map((role) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = role;
                        final studentText =
                            AuthPageLocalization.get('student', locale);
                        if (role != studentText) {
                          selectedGrade = null;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: selectedRole == role ? _kSoftBlue : _kFieldFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selectedRole == role ? _kPrimary : _kBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getRoleIcon(role),
                            color: selectedRole == role ? _kPrimary : _kMuted,
                            size: 20,
                          ),
                          const Gap(12),
                          Text(
                            role,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: selectedRole == role ? _kPrimary : _kInk,
                            ),
                          ),
                          const Spacer(),
                          if (selectedRole == role)
                            const Icon(
                              Icons.check,
                              color: _kPrimary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  )),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }

  void _showGradeBottomSheet(String locale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(20),
              Text(
                AuthPageLocalization.get('selectClass', locale),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _kInk,
                ),
              ),
              const Gap(16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: grades
                        .map((grade) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedGrade = grade;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: selectedGrade == grade
                                      ? _kSoftBlue
                                      : _kFieldFill,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selectedGrade == grade
                                        ? _kPrimary
                                        : _kBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      color: selectedGrade == grade
                                          ? _kPrimary
                                          : _kMuted,
                                      size: 20,
                                    ),
                                    const Gap(12),
                                    Text(
                                      locale == 'ru'
                                          ? '$grade класс'
                                          : '$grade-sinf',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: selectedGrade == grade
                                            ? _kPrimary
                                            : _kInk,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (selectedGrade == grade)
                                      const Icon(
                                        Icons.check,
                                        color: _kPrimary,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }

  IconData _getRoleIcon(String role) {
    if (role == 'O\'qituvchi' || role == 'Учитель') {
      return Icons.school_outlined;
    } else if (role == 'Ota-ona' || role == 'Родитель') {
      return Icons.family_restroom_outlined;
    } else {
      return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.stateStatus.isSuccess) {
              TopNotification.showSuccess(
                context,
                message: AuthPageLocalization.get('successLogin', locale),
              );
              if (state.role == 'student') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.main,
                  (route) => false,
                );
              } else if (state.role == 'parent') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.mainParent,
                  (route) => false,
                );
              } else if (state.role == 'tutor') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.mainTeacher,
                  (route) => false,
                );
              } else {
                TopNotification.showSuccess(
                  context,
                  message:
                      '${AuthPageLocalization.get('roleError', locale)} ${state.role}',
                );
              }
            }
            if (state.stateStatus.isError) {
              TopNotification.showError(
                context,
                message: state.errorMessage?.message ??
                    AuthPageLocalization.get('error', locale),
              );
            }
            if (state.registerStatus.isSuccess) {
              TopNotification.showSuccess(
                context,
                message: AuthPageLocalization.get('smsSent', locale),
              );
              Navigator.pushNamed(
                context,
                Routes.otp,
                arguments: OtpPageArgs(
                  phoneNumber: phoneController.text,
                  reset: false,
                ),
              );
            }
            if (state.registerStatus.isError) {
              TopNotification.showError(
                context,
                message: state.errorMessage?.message ??
                    AuthPageLocalization.get('error', locale),
              );
            }
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: _kScaffold,
              resizeToAvoidBottomInset: true,
              body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(locale),
                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: Column(
                          children: [
                            _buildAuthCard(locale),
                            const Gap(24),
                            _buildProtectedBadge(locale),
                            Gap(24 + MediaQuery.of(context).padding.bottom),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Hero — BACKGROUND.png ustida logo va sarlavha
  // ---------------------------------------------------------------------------
  Widget _buildHero(String locale) {
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final heroHeight = (width / 1.5).clamp(270.0, 350.0) + topPadding;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 10,
              left: 24,
              right: 24,
              bottom: 36,
            ),
            child: FractionallySizedBox(
              widthFactor: 0.74,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kPrimaryLight, _kPrimaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: _kPrimary.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'iQ',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const Gap(10),
                      const Text(
                        'MATH',
                        style: TextStyle(
                          fontSize: 30,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.22,
                        fontWeight: FontWeight.w800,
                      ),
                      children: [
                        TextSpan(
                          text:
                              AuthPageLocalization.get('heroTitlePrefix', locale),
                          style: const TextStyle(color: _kInk),
                        ),
                        TextSpan(
                          text: AuthPageLocalization.get(
                              'heroTitleHighlight', locale),
                          style: const TextStyle(color: _kPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Asosiy oq karta: tab + inputlar + tugma
  // ---------------------------------------------------------------------------
  Widget _buildAuthCard(String locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabs(locale),
          const Gap(22),
          if (selectedAuthType == 'register') ...[
                  _fieldLabel(AuthPageLocalization.get('fullName', locale)),
                  const Gap(8),
                  _iconField(
                    icon: Icons.person_outline,
                    hasError: _nameError != null,
                    isFocused: _nameFocusNode.hasFocus,
                    child: TextField(
                      controller: fullNameController,
                      focusNode: _nameFocusNode,
                      style: _inputTextStyle,
                      cursorColor: _kPrimary,
                      cursorWidth: 1.6,
                      cursorRadius: const Radius.circular(2),
                      decoration: _innerDecoration(
                        AuthPageLocalization.get('enterName', locale),
                      ),
                      onChanged: (name) {
                        setState(() {
                          _nameError = null;
                        });
                      },
                    ),
                  ),
                  _helperOrError(error: _nameError),
                  const Gap(18),
                ],
                _fieldLabel(AuthPageLocalization.get('phoneNumber', locale)),
                const Gap(8),
                _iconField(
                  icon: Icons.phone_in_talk_outlined,
                  hasError: _phoneError != null,
                  isFocused: _phoneFocusNode.hasFocus,
                  child: TextField(
                    controller: phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    style: _inputTextStyle,
                    cursorColor: _kPrimary,
                    cursorWidth: 1.6,
                    cursorRadius: const Radius.circular(2),
                    decoration: _innerDecoration("(__) ___-__-__").copyWith(
                      prefixText: "+998 ",
                      prefixStyle: _inputTextStyle,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      textInputFormatter,
                    ],
                    onChanged: (phone) {
                      setState(() {
                        _phoneError = null;
                      });
                      if (phone.length == 14 && selectedAuthType == 'login') {
                        _passwordFocusNode.requestFocus();
                      }
                    },
                  ),
                ),
                _helperOrError(error: _phoneError),
                const Gap(18),
                if (selectedAuthType == 'register') ...[
                  _fieldLabel(AuthPageLocalization.get('role', locale)),
                  const Gap(8),
                  _selectorField(
                    icon: selectedRole != null
                        ? _getRoleIcon(selectedRole!)
                        : Icons.people_alt_outlined,
                    text: selectedRole ??
                        AuthPageLocalization.get('selectRole', locale),
                    isSelected: selectedRole != null,
                    onTap: () => _showRoleBottomSheet(locale),
                  ),
                  if (selectedRole ==
                      AuthPageLocalization.get('student', locale)) ...[
                    const Gap(18),
                    _fieldLabel(AuthPageLocalization.get('class', locale)),
                    const Gap(8),
                    _selectorField(
                      icon: Icons.school_outlined,
                      text: selectedGrade != null
                          ? (locale == 'ru'
                              ? '$selectedGrade класс'
                              : '$selectedGrade-sinf')
                          : AuthPageLocalization.get('selectClass', locale),
                      isSelected: selectedGrade != null,
                      onTap: () => _showGradeBottomSheet(locale),
                    ),
                  ],
                  const Gap(24),
                ],
                if (selectedAuthType == 'login') ...[
                  _fieldLabel(AuthPageLocalization.get('password', locale)),
                  const Gap(8),
                  _iconField(
                    icon: Icons.lock_outline_rounded,
                    hasError: _passwordError != null,
                    isFocused: _passwordFocusNode.hasFocus,
                    child: TextField(
                      controller: passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      style: _inputTextStyle,
                      cursorColor: _kPrimary,
                      cursorWidth: 1.6,
                      cursorRadius: const Radius.circular(2),
                      decoration: _innerDecoration(
                        AuthPageLocalization.get('enterPassword', locale),
                      ),
                      onChanged: (password) {
                        setState(() {
                          _passwordError = null;
                        });
                      },
                    ),
                    trailing: IconButton(
                      splashRadius: 20,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _kMuted,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  _helperOrError(error: _passwordError),
                  const Gap(16),
                  Row(
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF94A3B8),
                            width: 1.6,
                          ),
                          activeColor: _kPrimary,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        AuthPageLocalization.get('rememberMe', locale),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _kInk,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.resetCode,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _kPrimary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AuthPageLocalization.get('forgotPassword', locale),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                ],
                _buildSubmitButton(locale),
                if (selectedAuthType == 'register') ...[
                  const Gap(16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: _kMuted,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: AuthPageLocalization.get('terms', locale),
                        ),
                        TextSpan(
                          text: AuthPageLocalization.get('termsOfUse', locale),
                          style: const TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: AuthPageLocalization.get('and', locale),
                        ),
                        TextSpan(
                          text:
                              AuthPageLocalization.get('privacyPolicy', locale),
                          style: const TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: AuthPageLocalization.get('termsAgree', locale),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab: Tizimga kirish / Ro'yxatdan o'tish
  // ---------------------------------------------------------------------------
  Widget _buildTabs(String locale) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Row(
        children: [
          _tabItem(
            label: AuthPageLocalization.get('systemEnter', locale),
            icon: Icons.person_outline,
            isActive: selectedAuthType == 'login',
            onTap: () => setState(() {
              selectedAuthType = 'login';
              _nameError = null;
            }),
          ),
          _tabItem(
            label: AuthPageLocalization.get('registration', locale),
            icon: Icons.lock_outline_rounded,
            isActive: selectedAuthType == 'register',
            onTap: () => setState(() {
              selectedAuthType = 'register';
              _passwordError = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [_kPrimaryLight, _kPrimaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _kPrimary.withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : _kMuted,
              ),
              const Gap(8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : _kMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Input yordamchilari
  // ---------------------------------------------------------------------------
  static const TextStyle _inputTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: _kInk,
  );

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _kInk,
      ),
    );
  }

  InputDecoration _innerDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF9AA7BC),
      ),
      isDense: true,
      // Global inputDecorationTheme'da `filled: true` va kulrang fillColor bor —
      // uni o'chirmasak, matn ortida kulrang quti ko'rinib qoladi.
      filled: false,
      fillColor: Colors.transparent,
      hoverColor: Colors.transparent,
      // Theme'dagi minHeight/maxHeight 56 cheklovini ham bekor qilamiz.
      constraints: const BoxConstraints(),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Chap tomonda ko'k ikonka kvadrati bo'lgan input
  Widget _iconField({
    required IconData icon,
    required Widget child,
    required bool hasError,
    required bool isFocused,
    Widget? trailing,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: hasError ? const Color(0xFFFFF6F6) : _kFieldFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasError
              ? _kError
              : isFocused
                  ? _kPrimary
                  : _kBorder,
          width: hasError || isFocused ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(left: 7, right: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPrimaryLight, _kPrimaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          Expanded(child: child),
          if (trailing != null) trailing else const Gap(12),
        ],
      ),
    );
  }

  /// Rol / sinf tanlash uchun bosiladigan maydon
  Widget _selectorField({
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: _kFieldFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _kPrimary : _kBorder,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(left: 7, right: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kPrimaryLight, _kPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? _kInk : const Color(0xFF9AA7BC),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _kMuted,
              size: 24,
            ),
            const Gap(12),
          ],
        ),
      ),
    );
  }

  Widget _helperOrError({String? error, String? helper}) {
    final text = error ?? helper;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: error != null ? _kError : _kMuted,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Asosiy tugma
  // ---------------------------------------------------------------------------
  Widget _buildSubmitButton(String locale) {
    final enabled = _canProceed();

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading =
            state.stateStatus.isLoading || state.registerStatus.isLoading;

        return GestureDetector(
          onTap: enabled && !isLoading ? _handleSubmit : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 62,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [_kPrimaryLight, _kPrimaryDark],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: enabled ? null : const Color(0xFFD8E1F0),
              borderRadius: BorderRadius.circular(18),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: _kPrimary.withOpacity(0.32),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: isLoading
                ? const Center(
                    child: CustomLoadingIndicator(
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        selectedAuthType == 'login'
                            ? AuthPageLocalization.get('systemEnter', locale)
                            : AuthPageLocalization.get('registration', locale),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color:
                              enabled ? Colors.white : const Color(0xFF8B9BB4),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(enabled ? 0.22 : 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 22,
                            color: enabled
                                ? Colors.white
                                : const Color(0xFF8B9BB4),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildProtectedBadge(String locale) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: _kPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
          const Gap(8),
          Text(
            AuthPageLocalization.get('dataProtected', locale),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _kPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
