import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/core/utils/snackbar_helper.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/model/TechnicianProfile_Model.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/services/EditProfile_Service.dart';
import 'package:tech_app/widgets/header.dart';
import 'package:tech_app/widgets/inputs/app_text_field.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';

class EditProfile extends StatefulWidget {
  final TechnicianProfile profile;

  const EditProfile({super.key, required this.profile});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _firstname;
  late TextEditingController _lastname;
  late TextEditingController _email;
  late TextEditingController _mobile;

  final _formKey = GlobalKey<FormState>();

  File? _selectImage;

  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  final EditprofileService _editprofileService = EditprofileService();

  @override
  void initState() {
    super.initState();

    _firstname = TextEditingController(
      text: widget.profile.data.firstName ?? "",
    );

    _lastname = TextEditingController(text: widget.profile.data.lastName ?? "");

    _email = TextEditingController(text: widget.profile.data.email ?? "");

    _mobile = TextEditingController(
      text: widget.profile.data.mobile?.toString() ?? "",
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectImage = File(image.path);
      });
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter valid email";
    }

    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Mobile number is required";
    }

    if (!RegExp(r'^[0-9]{8}$').hasMatch(value.trim())) {
      return "Mobile number must be 8 digits";
    }

    return null;
  }

  @override
  void dispose() {
    _firstname.dispose();
    _lastname.dispose();
    _email.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _updateprofile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() => _isLoading = true);

      final response = await _editprofileService.updateProfile(
        firstName: _firstname.text.trim(),
        lastName: _lastname.text.trim(),
        email: _email.text.trim().toLowerCase(),
        mobile: _mobile.text.trim(),
        image: _selectImage,
      );

      debugPrint("✅ UPDATE PROFILE RESPONSE: $response");

      if (!mounted) return;

      setState(() => _isLoading = false);

      SnackbarHelper.show(
        context,
        backgroundColor: AppColors.scoundry_clr,
        message: AppLocalizations.of(context)!.profileUpdatedSuccessfully,
      );

      Navigator.pop(context, true);
    } catch (e, stack) {
      setState(() => _isLoading = false);

      debugPrint("❌ ERROR: $e");
      debugPrint("❌ STACK: $stack");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.profile.data;
    final image = data.image;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// ✅ HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(
          title: AppLocalizations.of(context)!.editProfile,
          showBackButton: true,
          showNotificationIcon: false,
          showRefreshIcon: false,
          showProfileIcon: false,
          onBackPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteName.bottom_nav);
            }
          },
        ),
      ),

      /// ✅ BODY (SAFE SCROLL STRUCTURE)
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// PROFILE IMAGE
              Stack(
                children: [
                  Container(
                    height: 125,
                    width: 125,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary_clr.withOpacity(0.2),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant,

                      backgroundImage: _selectImage != null
                          ? FileImage(_selectImage!)
                          : (image != null && image.isNotEmpty)
                          ? CachedNetworkImageProvider(
                              '${ImageBaseUrl.baseUrl}/$image',
                            )
                          : null,

                      child:
                          (_selectImage == null &&
                              (image == null || image.isEmpty))
                          ? Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.grey.shade600,
                            )
                          : null,
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary_clr,
                          border: Border.all(
                            color: Theme.of(context).cardColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// NAME
              Text(
                "${data.firstName ?? ''} ${data.lastName ?? ''}",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 20),

              /// FORM CARD
              Form(
                key: _formKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: AppColors.primary_clr,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.personalInformation,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      AppTextField(
                        label: AppLocalizations.of(context)!.firstName,
                        controller: _firstname,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: AppLocalizations.of(context)!.lastName,
                        controller: _lastname,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: AppLocalizations.of(context)!.email,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: AppLocalizations.of(context)!.mobileNumber,
                        controller: _mobile,
                        keyboardType: TextInputType.number,
                        validator: validateMobile,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                      ),

                      const SizedBox(height: 28),

                      PrimaryButton(
                        radius: 14,
                        height: 54,
                        color: AppColors.primary_clr,
                        onPressed: _isLoading ? null : _updateprofile,
                        text: _isLoading
                            ? "Please wait..."
                            : AppLocalizations.of(context)!.saveChanges,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
