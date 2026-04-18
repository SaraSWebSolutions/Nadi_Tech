

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:tech_app/core/network/dio_client.dart';

class EditprofileService {
  final _dio = DioClient.dio;
 Future<Map<String, dynamic>> updateProfile({
  required String firstName,
  required String lastName,
  required String email,
  required String mobile,
  File? image,
}) async {
  try {
    final formData = FormData.fromMap({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "mobile": mobile,
      if (image != null)
        "image": await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
    });

    debugPrint("===== EDIT PROFILE FORM DATA =====");

    for (final field in formData.fields) {
      debugPrint("FIELD ➜ ${field.key}: ${field.value}");
    }

    for (final file in formData.files) {
      debugPrint("FILE ➜ ${file.key}: ${file.value.filename}");
    }

    debugPrint("=================================");

    final response = await _dio.post(
      'technician/update-profile',
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    debugPrint("✅ API RESPONSE: ${response.data}");

    return response.data; // ✅ VERY IMPORTANT
  } on DioException catch (e) {
    debugPrint("❌ API ERROR: ${e.response?.data}");
    throw e.response?.data["message"] ?? "Update failed";
  }

  }
}