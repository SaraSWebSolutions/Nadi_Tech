import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/model/ServiceList _Model.dart';
import 'dart:convert';

class ServicelistService {
  final _dio = DioClient.dio;
  Future<ServiceListModel> fetchServiceList({String status = 'all'}) async {
    try {
      final response = await _dio.post("techie/list?status=$status");
      print("API Response Status => ${response.data}");
      // debugPrint(
      //   jsonEncode(response.data),
      //   wrapWidth: 1024,
      // );
      return ServiceListModel.fromJson(response.data);
    } on DioException catch (e) {
      print("Dio Error => ${e.message}");
      print("Error Response => ${e.response?.data}");
      final errorData = e.response?.data;
      final message = errorData is Map<String, dynamic>
          ? errorData['message'] ?? 'Failed to load service list'
          : errorData.toString();

      throw Exception(message);
    }
  }
}
