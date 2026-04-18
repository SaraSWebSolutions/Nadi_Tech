import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/model/Chats_List_Model.dart';

class ChatsList {
  final _dio = DioClient.dio;

  Future<ChatModel> fetchchatlist() async {
    try {
      final response =
          await _dio.get("user-account/list-users-with-last-message");

      /// ✅ FULL RESPONSE LOG
      debugPrint("API RESPONSE => ${response.data}");

      final data = response.data;

      return ChatModel.fromJson(data);

    } on DioException catch (e) {

      /// ✅ ERROR LOG
      debugPrint("API ERROR => ${e.response?.data}");

      throw e.response?.data['message'] ?? "Something went wrong";
    }
  }
}
