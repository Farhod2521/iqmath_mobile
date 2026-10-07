import 'dart:io';

import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:my_flutter_template/core/widgets/soft_back_button.dart';
import 'package:my_flutter_template/features/profile/presentation/arguments/edit_profile_page_args.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../generated/l10n.dart';
import '../blocs/edit_profile/edit_profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final EditProfilePageArgs args;

  const EditProfilePage({super.key, required this.args});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  // final TextEditingController _dateOfBirthController =
  //     TextEditingController(text: '01.01.2002');
  // final TextEditingController _phoneNumberController = TextEditingController();
  var maskFormatter = MaskTextInputFormatter(
      mask: '## ### ## ##', filter: {"#": RegExp(r'^[\d+]+$')});

  @override
  void initState() {
    _nameController.text = widget.args.firstName;
    idController.text = widget.args.id;
    // phoneController.text = widget.args.phoneNumber.replaceAll('998', '');
    addressController.text = widget.args.address;
    phoneController.text = _prettyPhone(widget.args.phoneNumber);
    super.initState();
  }

  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _primary = Color(0xFF2563EB);

  String _t(String key) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    const uz = {
      'subtitle': "Profil ma'lumotlaringizni yangilang",
      'photoHint': 'Profil rasmini yuklang',
      'save': 'Saqlash',
    };
    const ruMap = {
      'subtitle': 'Обновите данные профиля',
      'photoHint': 'Загрузите фото профиля',
      'save': 'Сохранить',
    };
    return (ru ? ruMap : uz)[key] ?? key;
  }

  /// "998915812109" -> "+998 (91) 581-21-09"
  String _prettyPhone(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('998')) d = d.substring(3);
    if (d.length != 9) return raw;
    return '+998 (${d.substring(0, 2)}) ${d.substring(2, 5)}-${d.substring(5, 7)}-${d.substring(7)}';
  }

  void _pickPhoto(AppLocalization localization) {
    showCupertinoModalPopup(
      context: context,
      builder: (innerContext) => CupertinoActionSheet(
        title: Text(
          localization.change_photo,
          style: context.textStyle.fontSize12FontWeight400,
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              context
                  .read<EditProfileBloc>()
                  .add(const EditProfileChangeImage(isFromGallery: true));
              Navigator.pop(innerContext);
            },
            child: Text(
              localization.from_gallery,
              style: context.textStyle.fontSize16FontWeight700
                  .copyWith(color: context.color.primaryColor1),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              context
                  .read<EditProfileBloc>()
                  .add(const EditProfileChangeImage(isFromGallery: false));
              Navigator.pop(innerContext);
            },
            child: Text(
              localization.from_camera,
              style: context.textStyle.fontSize16FontWeight700
                  .copyWith(color: context.color.primaryColor1),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(innerContext),
          child: Text(
            localization.cancel,
            style: context.textStyle.fontSize16FontWeight700,
          ),
        ),
      ),
    );
  }

  Widget _avatarImage(EditProfileState state) {
    final placeholder = Container(
      color: const Color(0xFFE8F0FF),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, size: 96, color: _primary),
    );
    if (state.profileImageUrl != null) {
      return Image.file(File(state.profileImageUrl!), fit: BoxFit.cover);
    }
    if (widget.args.profilePhoto.isEmpty) return placeholder;
    return Image.network(
      widget.args.profilePhoto,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(child: CustomLoadingIndicator()),
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  Widget _sparkle(Color color, double size) =>
      Icon(Icons.auto_awesome, color: color, size: size);

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SoftBackButton(size: 52),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalization.of(context).edit,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _t('subtitle'),
                style: const TextStyle(fontSize: 14, color: _muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoBlock(AppLocalization localization) {
    return GestureDetector(
      onTap: () => _pickPhoto(localization),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(left: 14, top: 40, child: _sparkle(const Color(0xFF3B82F6), 18)),
                Positioned(right: 10, top: 34, child: _sparkle(const Color(0xFFFBBF24), 24)),
                Positioned(right: 16, top: 78, child: _sparkle(const Color(0xFF60A5FA), 14)),
                Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withOpacity(0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BlocBuilder<EditProfileBloc, EditProfileState>(
                      builder: (context, state) => _avatarImage(state),
                    ),
                  ),
                ),
                Positioned(
                  right: 44,
                  bottom: 6,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 21),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            localization.change_photo,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
          ),
          const SizedBox(height: 2),
          Text(
            _t('photoHint'),
            style: const TextStyle(fontSize: 13.5, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    FocusNode? focusNode,
    TextCapitalization capitalization = TextCapitalization.none,
    Widget? trailing,
    String? hint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        readOnly: readOnly,
                        focusNode: focusNode,
                        textCapitalization: capitalization,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: readOnly ? const Color(0xFF475569) : _ink,
                        ),
                        decoration: InputDecoration(
                          hintText: hint,
                          isCollapsed: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        ),
                      ),
                    ),
                    if (trailing != null)
                      Padding(padding: const EdgeInsets.only(right: 14), child: trailing),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _saveButton(AppLocalization localization) {
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listener: (context, state) => switch (state.status) {
        EditProfileStatus.idle || EditProfileStatus.loading => null,
        EditProfileStatus.success => {
            Navigator.pop(context, state.errorMessage?.message ?? ''),
          },
        EditProfileStatus.error => AppUtils.showSnackBar(
            context: context,
            message: state.errorMessage?.message ?? '',
            title: state.errorMessage?.title ?? '',
          ),
      },
      builder: (context, state) {
        final loading = state.status.isLoading;
        return GestureDetector(
          onTap: loading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  context.read<EditProfileBloc>().add(
                        EditProfileChangeInfoEvent(
                          firstName: _nameController.text,
                          address: addressController.text,
                          email: '',
                        ),
                      );
                },
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF2E9BFF), Color(0xFF2563EB), Color(0xFF4F7CF7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomLoadingIndicator(color: Colors.white),
                  )
                else
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, size: 18, color: _primary),
                  ),
                const SizedBox(width: 12),
                Text(
                  _t('save'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F0FC), Color(0xFFF5F8FE)],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  children: [
                    _header(),
                    const SizedBox(height: 18),
                    _photoBlock(localization),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0E1A4C).withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _field(
                            icon: Icons.badge_rounded,
                            iconColor: _primary,
                            iconBg: const Color(0xFFEAF1FF),
                            label: 'ID',
                            controller: idController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 18),
                          _field(
                            icon: Icons.person_rounded,
                            iconColor: _primary,
                            iconBg: const Color(0xFFEAF1FF),
                            label: localization.full_name,
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            capitalization: TextCapitalization.words,
                            hint: localization.enter_your_name,
                          ),
                          const SizedBox(height: 18),
                          _field(
                            icon: Icons.call_rounded,
                            iconColor: const Color(0xFF10B981),
                            iconBg: const Color(0xFFE6F8F1),
                            label: localization.phone_number,
                            controller: phoneController,
                            readOnly: true,
                            trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 18),
                          _field(
                            icon: Icons.location_on_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            iconBg: const Color(0xFFF1EBFF),
                            label: localization.address,
                            controller: addressController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: _saveButton(localization),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
