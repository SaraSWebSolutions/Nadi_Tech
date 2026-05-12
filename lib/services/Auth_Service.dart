import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/model/Auth_Model.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<Map<String, dynamic>> techLogin(AuthModel authmodel) async {
    try {
      final response = await _dio.post(
        "technician/login",
        data: authmodel.toJson(),
      );

      debugPrint("✅ LOGIN RESPONSE => ${response.data}");

      /// ✅ CHECK SUCCESS
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? "Login failed");
      }

      final token = response.data['token'];
      final techId = response.data['id'];

      /// ✅ VALIDATE TOKEN
      if (token == null || token.toString().isEmpty) {
        throw Exception(response.data['message'] ?? "Invalid login response");
      }

      await Appperfernces.saveToken(token);

      if (techId != null) {
        await Appperfernces.saveTechId(techId);
      }

      return response.data;
    } on DioException catch (e) {
      debugPrint("❌ LOGIN ERROR STATUS => ${e.response?.statusCode}");

      debugPrint("❌ LOGIN ERROR RESPONSE => ${e.response?.data}");

      final errorData = e.response?.data;

      String message = "Login failed";

      if (errorData is Map<String, dynamic>) {
        message = errorData['message']?.toString() ?? message;
      }

      throw Exception(message);
    } catch (e) {
      debugPrint("❌ UNKNOWN LOGIN ERROR => $e");

      String errorMessage = e.toString();

      // ✅ removes "Exception: "
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.replaceFirst("Exception: ", "");
      }

      throw errorMessage;
    }
  }

  Future<Map<String, dynamic>> updatepassword({required String email}) async {
    try {
      final response = await _dio.post(
        'technician/forgot-password',
        data: {"email": email},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? "someting went wrong ";
    }
  }
}
