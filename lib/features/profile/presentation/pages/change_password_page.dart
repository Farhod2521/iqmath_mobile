import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/widgets/custom_loading_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';

import '../../../../core/widgets/custom_animation_effects.dart';
import '../../../../injector_container.dart';

// ==================== LOCALIZATION CLASS ====================
class ChangePasswordLocalization {
  final String locale;

  ChangePasswordLocalization(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'title': 'Parolni o\'zgartirish',
      'currentPassword': 'Joriy parol',
      'newPassword': 'Yangi parol',
      'confirmPassword': 'Yangi parolni tasdiqlang',
      'saveButton': 'Saqlash',
      'errorCurrentEmpty': 'Joriy parolni kiriting',
      'errorNewEmpty': 'Yangi parolni kiriting',
      'errorNewTooShort': 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak',
      'errorConfirmEmpty': 'Parolni tasdiqlang',
      'errorPasswordMismatch': 'Parollar mos kelmaydi',
      'successMessage': 'Parol muvaffaqiyatli yangilandi.',
      'errorUnknown': 'Xatolik yuz berdi',
      'errorConnection': 'Internetga ulanishda xatolik',
      'errorTimeout': 'Server javob bermadi',
      'errorUnexpected': 'Kutilmagan xatolik yuz berdi',
    },
    'ru': {
      'title': 'Изменить пароль',
      'currentPassword': 'Текущий пароль',
      'newPassword': 'Новый пароль',
      'confirmPassword': 'Подтвердите новый пароль',
      'saveButton': 'Сохранить',
      'errorCurrentEmpty': 'Введите текущий пароль',
      'errorNewEmpty': 'Введите новый пароль',
      'errorNewTooShort': 'Пароль должен содержать минимум 6 символов',
      'errorConfirmEmpty': 'Подтвердите пароль',
      'errorPasswordMismatch': 'Пароли не совпадают',
      'successMessage': 'Пароль успешно обновлен.',
      'errorUnknown': 'Произошла ошибка',
      'errorConnection': 'Ошибка подключения к интернету',
      'errorTimeout': 'Сервер не ответил',
      'errorUnexpected': 'Произошла непредвиденная ошибка',
    },
  };

  String translate(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues['uz']![key]!;
  }

  // Getters
  String get title => translate('title');
  String get currentPassword => translate('currentPassword');
  String get newPassword => translate('newPassword');
  String get confirmPassword => translate('confirmPassword');
  String get saveButton => translate('saveButton');
  String get errorCurrentEmpty => translate('errorCurrentEmpty');
  String get errorNewEmpty => translate('errorNewEmpty');
  String get errorNewTooShort => translate('errorNewTooShort');
  String get errorConfirmEmpty => translate('errorConfirmEmpty');
  String get errorPasswordMismatch => translate('errorPasswordMismatch');
  String get successMessage => translate('successMessage');
  String get errorUnknown => translate('errorUnknown');
  String get errorConnection => translate('errorConnection');
  String get errorTimeout => translate('errorTimeout');
  String get errorUnexpected => translate('errorUnexpected');
}

// ==================== MAIN PAGE ====================
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  ChangePasswordLocalization _getLocalization() {
    final appState = context.read<AppBloc>().state;
    return ChangePasswordLocalization(appState.appLocale??'uz');
  }

  Future<void> _changePassword() async {
    final l10n = _getLocalization();

    setState(() {
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    if (_oldPasswordController.text.isEmpty) {
      setState(() {
        _oldPasswordError = l10n.errorCurrentEmpty;
      });
      isValid = false;
    }

    if (_newPasswordController.text.isEmpty) {
      setState(() {
        _newPasswordError = l10n.errorNewEmpty;
      });
      isValid = false;
    } else if (_newPasswordController.text.length < 6) {
      setState(() {
        _newPasswordError = l10n.errorNewTooShort;
      });
      isValid = false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = l10n.errorConfirmEmpty;
      });
      isValid = false;
    } else if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = l10n.errorPasswordMismatch;
      });
      isValid = false;
    }

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = sl<Dio>();
      final response = await dio.post(
        'https://api.iqmath.uz/api/v1/auth/user/change-password/',
        data: {
          'old_password': _oldPasswordController.text,
          'new_password': _newPasswordController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message'] as String? ?? l10n.successMessage;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      }
    } on DioException catch (e) {
      String errorMessage = l10n.errorUnknown;

      if (e.response != null) {
        if (e.response?.data is Map) {
          final data = e.response?.data as Map;
          errorMessage = data['message'] ??
              data['error'] ??
              data['detail'] ??
              l10n.errorUnknown;
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = l10n.errorConnection;
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = l10n.errorTimeout;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorUnexpected),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    String? errorText,
    required String fieldType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyle.fontSize14FontWeight700.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(10),
        TextField(
          controller: controller,
          obscureText: !isPasswordVisible,
          readOnly: _isLoading,
          onChanged: (value) {
            if (errorText != null) {
              setState(() {
                if (fieldType == 'old') {
                  _oldPasswordError = null;
                } else if (fieldType == 'new') {
                  _newPasswordError = null;
                } else {
                  _confirmPasswordError = null;
                }
              });
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            errorText: errorText,
            isDense: true,
            suffixIcon: UnconstrainedBox(
              child: ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onToggleVisibility,
                    splashColor: context.color.blackWhiteColor.withOpacity(0.1),
                    hoverColor: context.color.blackWhiteColor.withOpacity(0.05),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: context.color.blackWhiteColor.withOpacity(0.5),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          textInputAction: TextInputAction.done,
          style: context.textStyle.fontSize16FontWeight700.copyWith(
            color: context.color.blackWhiteColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final l10n = ChangePasswordLocalization(state.appLocale??'uz');

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: const SizedBox.shrink(),
          ),
          body: SafeArea(
            minimum: const EdgeInsets.only(
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Divider(),
                ),
                const SliverGap(24),
                SliverToBoxAdapter(
                  child: _buildPasswordField(
                    label: l10n.currentPassword,
                    controller: _oldPasswordController,
                    isPasswordVisible: _isOldPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                    errorText: _oldPasswordError,
                    fieldType: 'old',
                  ),
                ),
                const SliverGap(24),
                SliverToBoxAdapter(
                  child: _buildPasswordField(
                    label: l10n.newPassword,
                    controller: _newPasswordController,
                    isPasswordVisible: _isNewPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                    errorText: _newPasswordError,
                    fieldType: 'new',
                  ),
                ),
                const SliverGap(24),
                SliverToBoxAdapter(
                  child: _buildPasswordField(
                    label: l10n.confirmPassword,
                    controller: _confirmPasswordController,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    errorText: _confirmPasswordError,
                    fieldType: 'confirm',
                  ),
                ),
                const SliverGap(55),
                SliverToBoxAdapter(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Center(
                            child: Text(l10n.saveButton),
                          ),
                        ),
                        if (_isLoading)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CustomLoadingIndicator(
                                  color: context.color.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate(
                    effects: slideAndFadeEffect,
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