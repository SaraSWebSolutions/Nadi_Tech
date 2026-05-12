import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/routes/app_route.dart';

class DioClient {
  static final GlobalKey<NavigatorState> navigatorKey = rootNavigatorKey;

  // ✅ prevent multiple logout calls
  static bool _isLoggingOut = false;
  static final ValueNotifier<bool> loader = ValueNotifier(false);
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: "https://srv1252888.hstgr.cloud/api/",
            responseType: ResponseType.json,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),

            // ✅ allow interceptor to handle 401/403
            validateStatus: (status) {
              return status != null && status < 500;
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            // ================= REQUEST =================
            onRequest: (options, handler) async {
              final token = await Appperfernces.getToken();

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }

              handler.next(options);
            },

            // ================= RESPONSE =================
            onResponse: (response, handler) async {
              final statusCode = response.statusCode ?? 0;

              debugPrint(
                "RESPONSE => ${response} "
                "${response.requestOptions.path} "
                "STATUS: $statusCode",
              );

              final path = response.requestOptions.path;

              String message = "Something went wrong";

              final data = response.data;

              if (data != null && data is Map<String, dynamic>) {
                final msg = data['message'];

                if (msg != null) {
                  message = msg.toString();
                }
              }

              if (path.contains("technician/login")) {
                return handler.next(response);
              }

              if (statusCode == 401) {
                debugPrint("401 LOGOUT => $message");

                await _handleLogout(message);

                return handler.reject(
                  DioException(
                    requestOptions: response.requestOptions,
                    response: response,
                    type: DioExceptionType.badResponse,
                    error: message,
                  ),
                );
              }

              if (statusCode == 403) {
                debugPrint("403 LOGOUT => $message");

                await _handleLogout(message);

                return handler.reject(
                  DioException(
                    requestOptions: response.requestOptions,
                    response: response,
                    type: DioExceptionType.badResponse,
                    error: message,
                  ),
                );
              }

              handler.next(response);
            },
            // ================= ERROR =================
            onError: (DioException error, handler) async {
              final statusCode = error.response?.statusCode ?? 0;

              debugPrint(
                "ERROR => ${error.requestOptions.method} "
                "${error.requestOptions.path} "
                "STATUS: $statusCode",
              );

              final path = error.requestOptions.path;

              if (path.contains("technician/login")) {
                return handler.next(error);
              }

              String message = "Something went wrong";

              final data = error.response?.data;

              if (data != null && data is Map<String, dynamic>) {
                final msg = data['message'];

                if (msg != null) {
                  message = msg.toString();
                }
              }

              if (statusCode == 401 || statusCode == 403) {
                debugPrint("AUTH ERROR => $message");

                await _handleLogout(message);

                return handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    response: error.response,
                    type: DioExceptionType.badResponse,
                    error: message,
                  ),
                );
              }

              return handler.next(error);
            },
          ),
        );

  // ================= LOGOUT =================
  static Future<void> _handleLogout(String message) async {
    if (_isLoggingOut) return;

    _isLoggingOut = true;

    loader.value = true;

    debugPrint("AUTH ERROR: $message");

    await Appperfernces.clearAll();

    final context = navigatorKey.currentContext;

    if (context != null) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),

          backgroundColor: Colors.red,

          behavior: SnackBarBehavior.floating,

          margin: const EdgeInsets.all(16),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          duration: const Duration(seconds: 2),
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));

    /// ✅ GOROUTER REDIRECT
    Approute.go(RouteName.login);

    loader.value = false;

    _isLoggingOut = false;
  }
}

class ImageBaseUrl {
  static const baseUrl = "https://srv1252888.hstgr.cloud/uploads";
}
