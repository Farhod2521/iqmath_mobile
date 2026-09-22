import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:dio/dio.dart';
import 'package:my_flutter_template/features/auth/presentation/page_args/auth_page_localization.dart';

import '../../../../core/app_bloc/app_bloc.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? phoneNumber;

  const ResetPasswordPage({
    super.key,
    this.phoneNumber,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final TextEditingController phoneController;
  late final TextEditingController newPasswordController;
  late final Dio _dio;
  late final MaskTextInputFormatter textInputFormatter;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _passwordFocusNode;

  String? _phoneError;
  String? _passwordError;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    phoneController = TextEditingController();
    newPasswordController = TextEditingController();
    _phoneFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    textInputFormatter = MaskTextInputFormatter(
      mask: "(##) ###-##-##",
      filter: {"#": RegExp(r'[0-9]')},
    );

    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.iqmath.uz/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    if (widget.phoneNumber != null) {
      final cleanedPhone = widget.phoneNumber!
          .replaceAll('+998', '')
          .replaceAll(RegExp(r'[^\d]'), '');
      phoneController.text = textInputFormatter.maskText(cleanedPhone);
    }

    _phoneFocusNode.addListener(_onPhoneFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  void _onPhoneFocusChange() {
    if (!_phoneFocusNode.hasFocus) {
      _validatePhone();
    }
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocusNode.hasFocus) {
      _validatePassword();
    }
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_onPhoneFocusChange);
    _passwordFocusNode.removeListener(_onPasswordFocusChange);

    phoneController.dispose();
    newPasswordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _dio.close();

    super.dispose();
  }

  void _validatePhone() {
    if (!mounted) return;

    final locale = context.read<AppBloc>().state.appLocale??'uz';
    setState(() {
      if (phoneController.text.isEmpty) {
        _phoneError = ResetPasswordLocalization.get('phoneError', locale);
      } else if (phoneController.text.length < 14) {
        _phoneError = ResetPasswordLocalization.get('phoneIncomplete', locale);
      } else {
        _phoneError = null;
      }
    });
  }

  void _validatePassword() {
    if (!mounted) return;

    final locale = context.read<AppBloc>().state.appLocale??'uz';
    setState(() {
      if (newPasswordController.text.isEmpty) {
        _passwordError = ResetPasswordLocalization.get('passwordError', locale);
      } else if (newPasswordController.text.length < 6) {
        _passwordError = ResetPasswordLocalization.get('passwordShort', locale);
      } else {
        _passwordError = null;
      }
    });
  }

  bool _canProceed() {
    return phoneController.text.length >= 14 &&
        newPasswordController.text.length >= 6;
  }

  Future<String> _resetPassword(String phone, String newPassword, String locale) async {
    try {
      final response = await _dio.post(
        '/auth/student/reset-password/',
        data: {
          'phone': phone,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return response.data['message'] ??
            ResetPasswordLocalization.get('successMessage', locale);
      } else {
        throw Exception(
            response.data['message'] ??
                ResetPasswordLocalization.get('error', locale)
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ??
                ResetPasswordLocalization.get('serverError', locale)
        );
      } else {
        throw Exception(
            ResetPasswordLocalization.get('internetError', locale)
        );
      }
    } catch (e) {
      throw Exception(ResetPasswordLocalization.get('error', locale));
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
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
    _validatePassword();

    if (_phoneError != null || _passwordError != null) return;

    final locale = context.read<AppBloc>().state.appLocale??'uz';
    final cleanPhone = phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final fullPhone = '998$cleanPhone';

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await _resetPassword(
        fullPhone,
        newPasswordController.text,
        locale,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSuccessSnackBar(message);

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.of(context)
        ..pop()
        ..pop()
        ..pop();
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
              ResetPasswordLocalization.get('resetPassword', locale),
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
                  ResetPasswordLocalization.get('resetPasswordTitle', locale),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Gap(8),
                Text(
                  ResetPasswordLocalization.get('resetPasswordDesc', locale),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const Gap(32),

                // Phone Number Field
                Text(
                  ResetPasswordLocalization.get('phoneNumber', locale),
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
                    if (phone.length == 14) {
                      _passwordFocusNode.requestFocus();
                    }
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

                const Gap(24),

                // New Password Field
                Text(
                  ResetPasswordLocalization.get('newPassword', locale),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Gap(8),
                TextField(
                  controller: newPasswordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: ResetPasswordLocalization.get('enterNewPassword', locale),
                    filled: true,
                    fillColor: _passwordError != null
                        ? const Color(0xFFFFF1F1)
                        : const Color(0xFFF8F9FA),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _passwordError != null
                            ? const Color(0xFFDC3545)
                            : Colors.transparent,
                        width: _passwordError != null ? 1 : 0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _passwordError != null
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
                  onChanged: (password) {
                    setState(() {
                      _passwordError = null;
                    });
                  },
                ),
                if (_passwordError != null) ...[
                  const Gap(4),
                  Text(
                    _passwordError!,
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
                    onPressed:
                    _canProceed() && !_isLoading ? _handleSubmit : null,
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
                      ResetPasswordLocalization.get('finish', locale),
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
                      ResetPasswordLocalization.get('backToLogin', locale),
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