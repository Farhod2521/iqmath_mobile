import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:dio/dio.dart';
import 'package:my_flutter_template/core/widgets/top_notification.dart';
import 'package:my_flutter_template/features/auth/presentation/page_args/auth_args.dart';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../router/name_routes.dart';

class ResetCodeLocalization {
  static Map<String, Map<String, String>> translations = {
    'uz': {
      'resetPassword': 'Parolni tiklash',
      'resetPasswordTitle': 'Parolni tiklash',
      'resetPasswordDesc': 'Telefon raqamingizni kiriting va biz sizga tasdiqlash kodini yuboramiz',
      'phoneNumber': 'Telefon raqam',
      'sendCode': 'Kodni yuborish',
      'backToLogin': 'Tizimga kirishga qaytish',
      'phoneError': 'Telefon raqamini kiriting',
      'phoneIncomplete': 'Telefon raqam to\'liq emas',
      'smsSent': 'Telefon raqamga SMS kodi yuborildi. Kodni tasdiqlang.',
      'error': 'Xatolik yuz berdi',
      'serverError': 'Server xatosi',
      'internetError': 'Internet bilan bog\'liq muammo',
    },
    'ru': {
      'resetPassword': 'Восстановить пароль',
      'resetPasswordTitle': 'Восстановление пароля',
      'resetPasswordDesc': 'Введите номер телефона и мы отправим вам код подтверждения',
      'phoneNumber': 'Номер телефона',
      'sendCode': 'Отправить код',
      'backToLogin': 'Вернуться к входу',
      'phoneError': 'Введите номер телефона',
      'phoneIncomplete': 'Номер телефона неполный',
      'smsSent': 'SMS код отправлен на номер телефона. Подтвердите код.',
      'error': 'Произошла ошибка',
      'serverError': 'Ошибка сервера',
      'internetError': 'Проблема с интернетом',
    },
  };

  static String get(String key, String locale) {
    return translations[locale]?[key] ?? translations['uz']![key]!;
  }
}

class ResetCodeNumberPage extends StatefulWidget {
  const ResetCodeNumberPage({super.key});

  @override
  State<ResetCodeNumberPage> createState() => _ResetCodeNumberPageState();
}

class _ResetCodeNumberPageState extends State<ResetCodeNumberPage> {
  late final TextEditingController phoneController;
  late final Dio _dio;
  late final MaskTextInputFormatter textInputFormatter;
  late final FocusNode _phoneFocusNode;

  String? _phoneError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    phoneController = TextEditingController();
    _phoneFocusNode = FocusNode();

    textInputFormatter = MaskTextInputFormatter(
      mask: "(##) ###-##-##",
      filter: {"#": RegExp(r'[0-9]')},
    );

    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.iqmath.uz/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _phoneFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_phoneFocusNode.hasFocus) {
      _validatePhone();
    }
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_onFocusChange);
    _phoneFocusNode.dispose();
    phoneController.dispose();
    _dio.close();
    super.dispose();
  }

  void _validatePhone() {
    if (!mounted) return;

    final locale = context.read<AppBloc>().state.appLocale??'uz';
    setState(() {
      if (phoneController.text.isEmpty) {
        _phoneError = ResetCodeLocalization.get('phoneError', locale);
      } else if (phoneController.text.length < 14) {
        _phoneError = ResetCodeLocalization.get('phoneIncomplete', locale);
      } else {
        _phoneError = null;
      }
    });
  }

  bool _canProceed() {
    return phoneController.text.length >= 14;
  }

  Future<void> _sendResetCode(String phone, String locale) async {
    try {
      final response = await _dio.post(
        '/auth/student/forgot-password/',
        data: {'phone': phone},
      );

      debugPrint('Response: ${response.toString()}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(
            response.data['error'] ??
                ResetCodeLocalization.get('error', locale)
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.response?.data}');

      if (e.response != null) {
        throw Exception(
            e.response?.data['error'] ??
                ResetCodeLocalization.get('serverError', locale)
        );
      } else {
        throw Exception(ResetCodeLocalization.get('internetError', locale));
      }
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception(ResetCodeLocalization.get('error', locale));
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_canProceed()) return;

    _validatePhone();
    if (_phoneError != null) return;

    final locale = context.read<AppBloc>().state.appLocale??'uz';
    final cleanPhone = phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final fullPhone = '998$cleanPhone';

    setState(() {
      _isLoading = true;
    });

    try {
      await _sendResetCode(fullPhone, locale);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      TopNotification.showSuccess(
        context,
        message: ResetCodeLocalization.get('smsSent', locale),
      );

      Navigator.pushNamed(
        context,
        Routes.otp,
        arguments: OtpPageArgs(
          phoneNumber: phoneController.text,
          reset: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale??'uz';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              ResetCodeLocalization.get('resetPassword', locale),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  ResetCodeLocalization.get('resetPasswordTitle', locale),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Gap(8),
                Text(
                  ResetCodeLocalization.get('resetPasswordDesc', locale),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const Gap(40),

                // Phone Number Field
                Text(
                  ResetCodeLocalization.get('phoneNumber', locale),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Gap(8),
                TextField(
                  controller: phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "(00) 000-00-00",
                    prefixText: "+998 ",
                    prefixStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                    filled: true,
                    fillColor: _phoneError != null
                        ? const Color(0xFFFFF1F1)
                        : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _phoneError != null
                            ? const Color(0xFFDC3545)
                            : Colors.transparent,
                        width: _phoneError != null ? 1 : 0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _phoneError != null
                            ? const Color(0xFFDC3545)
                            : const Color(0xFF007AFF),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    textInputFormatter,
                  ],
                  onChanged: (phone) {
                    setState(() {
                      _phoneError = null;
                    });
                  },
                ),
                if (_phoneError != null) ...[
                  const Gap(4),
                  Text(
                    _phoneError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFDC3545),
                    ),
                  ),
                ],

                const Gap(40),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canProceed() && !_isLoading
                        ? _handleSubmit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canProceed() && !_isLoading
                          ? const Color(0xFF4A7AFF)
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      ResetCodeLocalization.get('sendCode', locale),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const Gap(24),

                // Back to login
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF007AFF),
                    ),
                    child: Text(
                      ResetCodeLocalization.get('backToLogin', locale),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
}