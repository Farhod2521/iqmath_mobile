import 'dart:io';

import 'package:flutter_svg/svg.dart';
import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:my_flutter_template/core/widgets/appbar_leading_widget.dart';
import 'package:my_flutter_template/core/widgets/custom_cached_network_image.dart';
import 'package:my_flutter_template/features/profile/presentation/arguments/edit_profile_page_args.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:my_flutter_template/router/app_routes.dart';

import '../../../../core/utils/base_utils.dart';
import '../../../../core/widgets/custom_animation_effects.dart';
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
    phoneController.text =
        BaseFunctions.formatPhoneNumber(widget.args.phoneNumber, format: ' ')
            .replaceAll('998', '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.edit,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: SizedBox.shrink(),
        // leading:  Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     AppbarLeadingWidget(
        //       withBackground: true,
        //     ),
        //   ],
        // ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(
          bottom: 20,
          left: 20,
          right: 20,
        ),
        child: CustomScrollView(
          slivers: [
            const SliverGap(24),
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
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
                            context.read<EditProfileBloc>().add(
                                  const EditProfileChangeImage(
                                    isFromGallery: true,
                                  ),
                                );
                            Navigator.pop(context);
                          },
                          child: Text(
                            localization.from_gallery,
                            style: context.textStyle.fontSize16FontWeight700
                                .copyWith(
                              color: context.color.primaryColor1,
                            ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            context.read<EditProfileBloc>().add(
                                  const EditProfileChangeImage(
                                    isFromGallery: false,
                                  ),
                                );
                            Navigator.pop(context);
                          },
                          child: Text(
                            localization.from_camera,
                            style: context.textStyle.fontSize16FontWeight700
                                .copyWith(
                              color: context.color.primaryColor1,
                            ),
                          ),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          localization.cancel,
                          style: context.textStyle.fontSize16FontWeight700,
                        ),
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    BlocBuilder<EditProfileBloc, EditProfileState>(
                      builder: (context, state) {
                        if (state.profileImageUrl == null) {
                          return ClipRRect(
                            borderRadius: AppUtils.kBorderRadius10,
                            child: Container(
                              height: 110,
                              width: 110,
                              color: context.color.homeButtonsColor,
                              child: Image.network(
                                widget.args.profilePhoto,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  return progress == null
                                      ? child
                                      : const Center(
                                          child: CustomLoadingIndicator(),
                                        );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Image.asset(
                                      Assets.pngUser,
                                      fit: BoxFit.cover,
                                      color: context.color.primaryColor1,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              color: context.color.homeButtonsColor,
                              borderRadius: AppUtils.kBorderRadius12,
                            ),
                            child: ClipRRect(
                              borderRadius: AppUtils.kBorderRadius12,
                              child: Image.file(
                                File(state.profileImageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const Gap(16),
                    Text(
                      localization.change_photo,
                      // 'Rasimni o\'zgartirish',
                      style: context.textStyle.fontSize14FontWeight400,
                    ),
                  ],
                ),
              ).animate(
                effects: slideAndFadeEffect,
              ),
            ),
            const SliverGap(24),
            const SliverToBoxAdapter(
              child: Divider(),
            ),
            const SliverGap(24),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // localization.phone_number,
                    'ID',
                    style: context.textStyle.fontSize14FontWeight700.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(10),
                  TextField(
                    onChanged: (value) {},
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    controller: idController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    style: context.textStyle.fontSize16FontWeight700.copyWith(
                      color: context.color.blackWhiteColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SliverGap(16),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.full_name,
                    // 'To\'liq ism',
                    style: context.textStyle.fontSize14FontWeight700.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(10),
                  TextField(
                    onChanged: (value) {},
                    focusNode: _nameFocusNode,
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      // BaseFunctions.onlyLettersFormatter,
                      // LengthLimitingTextInputFormatter(15),
                    ],
                    style: context.textStyle.fontSize16FontWeight700.copyWith(
                      color: context.color.blackWhiteColor.withOpacity(0.5),
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: localization.enter_your_name,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ].animate(
                  effects: slideAndFadeEffect,
                ),
              ),
            ),
            const SliverGap(16),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.phone_number,
                    // 'Telefon raqami',
                    style: context.textStyle.fontSize14FontWeight700.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(10),
                  TextField(
                    onChanged: (value) {},
                    controller: phoneController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    style: context.textStyle.fontSize16FontWeight700.copyWith(
                      color: context.color.blackWhiteColor.withOpacity(0.5),
                    ),
                    readOnly: true,
                    inputFormatters: [
                      maskFormatter,
                    ],
                    decoration: const InputDecoration(
                      prefixText: "+998 ",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SliverGap(16),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.address,
                    // 'Manzil',
                    style: context.textStyle.fontSize14FontWeight700.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(10),
                  TextField(
                    onChanged: (value) {},
                    controller: addressController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    style: context.textStyle.fontSize16FontWeight700.copyWith(
                      color: context.color.blackWhiteColor.withOpacity(0.5),
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SliverGap(55),
            SliverToBoxAdapter(
              child: BlocConsumer<EditProfileBloc, EditProfileState>(
                listener: (context, state) => switch (state.status) {
                  EditProfileStatus.idle || EditProfileStatus.loading => null,
                  EditProfileStatus.success => {
                      Navigator.pop(context,state.errorMessage?.message??''),
                    },
                  EditProfileStatus.error => AppUtils.showSnackBar(
                      context: context,
                      message: state.errorMessage?.message ?? '',
                      title: state.errorMessage?.title ?? '',
                    ),
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.status.isLoading
                        ? () {}
                        : () {
                            context.read<EditProfileBloc>().add(
                                  EditProfileChangeInfoEvent(
                                    firstName: _nameController.text,
                                    address: addressController.text,
                                    email: '',
                                    // phoneNumber: '+998${maskFormatter.getUnmaskedText()}',
                                  ),
                                );
                          },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Center(
                            child: Text(localization.save_changes),
                            // child: Text('Saqlash'),
                          ),
                        ),
                        if (state.status.isLoading)
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
