import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:tech_app/core/network/dio_client.dart';

class AcceptrequestService {
  final _dio = DioClient.dio;

  Future<Map<String, dynamic>?> acceptrequest(
    String assignmentId,
    String action, String? reason
   
  ) async {

    try {
      
      final response = await _dio.post(
        'user-service-list/technician-respond',
        data: {
          "assignmentId":assignmentId,
          "action":action,
          "reason": reason
        }
        );
            debugPrint("=== ACCEPT/REJECT RESPONSE ===");
    debugPrint(response.data.toString());
    debugPrint("================================");

      return response.data;
    } on DioException catch (e) {

      final errorData = e.response?.data;
      final message = errorData is Map<String, dynamic>
          ? errorData['message'] ?? 'Failed to load service list'
          : errorData.toString();
      throw Exception(message);
    }
  }
}
