import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/core/utils/snackbar_helper.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/model/TechnicianProfile_Model.dart';
import 'package:tech_app/services/EditProfile_Service.dart';
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

_lastname = TextEditingController(
  text: widget.profile.data.lastName ?? "",
);

_email = TextEditingController(
  text: widget.profile.data.email ?? "",
);

_mobile = TextEditingController(
  text: widget.profile.data.mobile?.toString() ?? "",
);
  }

  Future<void> _PickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectImage = File(image.path);
      });
    }
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
  try {
    setState(() => _isLoading = true);

    final response = await _editprofileService.updateProfile(
      firstName: _firstname.text.trim(),
      lastName: _lastname.text.trim(),
      email: _email.text.trim(),
      mobile: _mobile.text.trim(),
      image: _selectImage,
    );

    debugPrint("✅ UPDATE PROFILE RESPONSE: $response");

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final image = widget.profile.data.image;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                   backgroundImage: _selectImage != null
    ? FileImage(_selectImage!)
    : (image != null && image.isNotEmpty)
        ? CachedNetworkImageProvider(
            '${ImageBaseUrl.baseUrl}/$image',
          )
        : null,
                   child: (_selectImage == null && (image == null || image.isEmpty))
    ? const Icon(Icons.person, size: 90)
    : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => _PickImage(),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary_clr,
                      ),
                      child: Icon(Icons.edit_outlined, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${widget.profile.data.firstName} ${widget.profile.data.lastName}",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(15),
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                         AppLocalizations.of(context)!.personalInformation,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),

                        _label(AppLocalizations.of(context)!.firstName),
                        const SizedBox(height: 15),
                        AppTextField(
                          label: AppLocalizations.of(context)!.firstName,
                          controller: _firstname,
                        ),
                        const SizedBox(height: 10),
                        _label(AppLocalizations.of(context)!.lastName),
                        const SizedBox(height: 15),
                        AppTextField(label: AppLocalizations.of(context)!.lastName, controller: _lastname),

                        const SizedBox(height: 10),

                        _label( AppLocalizations.of(context)!.email),
                        const SizedBox(height: 15),
                        AppTextField(label:  AppLocalizations.of(context)!.email, controller: _email),

                        const SizedBox(height: 10),
                        _label(AppLocalizations.of(context)!.mobileNumber),
                        const SizedBox(height: 15),
                        AppTextField(
                          label: AppLocalizations.of(context)!.mobileNumber,
                          controller: _mobile,
                          keyboardType: TextInputType.phone,
 
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          radius: 12,
                          height: 50,
                          color: AppColors.primary_clr,
                          onPressed: () {
                            _updateprofile();
                          },
                          text: AppLocalizations.of(context)!.saveChanges,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16,color: Colors.black),
    );
  }
}
