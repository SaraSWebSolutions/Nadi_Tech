import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:tech_app/core/network/dio_client.dart';

class UpdateService {
  final _dio = DioClient.dio;

  //service on hold
  Future<Map<String, dynamic>> fetchonhold({
    required String userServiceId,
  }) async {
    try {
      final response = await _dio.post(
        "techie/hold-work",
        data: {"userServiceId": userServiceId},
      );

      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;

      final message = errorData is Map<String, dynamic>
          ? errorData['message'] ?? 'Something went wrong'
          : errorData.toString();

      throw message;
    }
  }

  // Updated Service
  //   Future<Map<String, dynamic>> fetchupdatedservice({
  //     required List<File> images,
  //     required String userServiceId,
  //     required String serviceStatus,
  //     required String notes,
  //     File? voice,
  //   }) async {
  //     try {
  //       final formData = FormData();

  //       formData.fields.addAll([
  //   MapEntry("userServiceId", userServiceId),
  //   MapEntry("serviceStatus", serviceStatus),
  //   MapEntry("notes", notes), // ✅ ADD THIS
  // ]);

  //       //  Images (multiple)
  //       for (var image in images) {
  //         formData.files.add(
  //           MapEntry(
  //             "media[]",
  //             await MultipartFile.fromFile(
  //               image.path,
  //               filename: image.path.split('/').last,
  //             ),
  //           ),
  //         );
  //       }

  //       // Voice note (optional)
  //       if (voice != null) {
  //         formData.files.add(
  //           MapEntry(
  //             "voice",
  //             await MultipartFile.fromFile(
  //               voice.path,
  //               filename: voice.path.split('/').last,
  //             ),
  //           ),
  //         );
  //       }

  //       final response = await _dio.post(
  //         "techie/update-service",
  //         data: formData,
  //         options: Options(contentType: "multipart/form-data"),
  //       );
  //       return response.data;
  //     } on DioException catch (e) {

  //       final errorData = e.response?.data;

  //       final message = errorData is Map<String, dynamic>
  //           ? errorData['message'] ?? 'Something went wrong'
  //           : errorData.toString();

  //       throw message;
  //     }
  //   }
  Future<Map<String, dynamic>> fetchupdatedservice({
    required List<File> images,
    required String userServiceId,
    required String serviceStatus,
    required String notes,
    File? voice,
  }) async {
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry("userServiceId", userServiceId),
        MapEntry("serviceStatus", serviceStatus),
        MapEntry("notes", notes), // ✅ FIX
      ]);

      for (var image in images) {
        formData.files.add(
          MapEntry(
            "media[]",
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      if (voice != null) {
        formData.files.add(
          MapEntry(
            "voice",
            await MultipartFile.fromFile(
              voice.path,
              filename: voice.path.split('/').last,
            ),
          ),
        );
      }
      debugPrint("========== REQUEST SENT ==========");
      for (var field in formData.fields) {
        debugPrint("FIELD => ${field.key} : ${field.value}");
      }

      for (var file in formData.files) {
        debugPrint("FILE => ${file.key} : ${file.value.filename}");
      }
      final response = await _dio.post(
        "techie/update-service",
        data: formData,
        //options: Options(contentType: Headers.multipartFormDataContentType),
      );
      debugPrint("========== SUCCESS RESPONSE ==========");
      debugPrint("STATUS CODE => ${response.statusCode}");
      debugPrint("DATA => ${response.data}");
      return response.data;
    } on DioException catch (e) {
      // =====================
      // ERROR LOG
      // =====================
      debugPrint("========== DIO ERROR ==========");
      debugPrint("STATUS CODE => ${e.response?.statusCode}");
      debugPrint("MESSAGE => ${e.message}");

      if (e.response != null) {
        debugPrint("ERROR DATA => ${e.response?.data}");
      } else {
        debugPrint("NO RESPONSE RECEIVED FROM SERVER");
      }

      final errorData = e.response?.data;

      final message = errorData is Map<String, dynamic>
          ? errorData['message'] ?? 'Something went wrong'
          : errorData.toString();

      throw message;
    }
  }
}
