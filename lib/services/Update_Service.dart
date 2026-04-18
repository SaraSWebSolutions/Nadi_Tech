import 'dart:io';

import 'package:dio/dio.dart';

import 'package:tech_app/core/network/dio_client.dart';

class UpdateService {
  final _dio = DioClient.dio;
   
   //service on hold
   Future<Map<String,dynamic>> fetchonhold({
    required String userServiceId
   })async{
     try{
          final response = await _dio.post(
            "techie/hold-work",
               data: {
                "userServiceId":userServiceId
               }
            );
     
            return response.data;
     }on DioException catch(e){
      final errorData = e.response?.data;

      final message = errorData is Map<String, dynamic>
          ? errorData['message'] ?? 'Something went wrong'
          : errorData.toString();

      throw message;
     }
   }

   // Updated Service
  Future<Map<String, dynamic>> fetchupdatedservice({
    required List<File> images,
    required String userServiceId,
    required String serviceStatus,
    File? voice,
  }) async {
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry("userServiceId", userServiceId),
        MapEntry("serviceStatus", serviceStatus),
      ]);

      //  Images (multiple)
      for (var image in images) {
        formData.files.add(
          MapEntry(
            "media",
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      // Voice note (optional)
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

      final response = await _dio.post(
        "techie/update-service",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
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
}
