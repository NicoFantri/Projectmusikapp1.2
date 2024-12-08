import 'dart:convert';
import 'dart:developer';

import 'package:musicapp/app/data/repository/music_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkService {
  static Dio initDio() {
    final options = BaseOptions(
      baseUrl: "https://api.spotify.com/v1/",
      receiveTimeout: const Duration(seconds: 60),
    );
    var dio = Dio(options);

    String method = "POST";

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String accessToken = prefs.getString('spotifyToken') ?? '';
        if (accessToken.isEmpty) {
          log('Access token is empty. Generating new token...');
          await MusicRepo.generateToken();
          accessToken = prefs.getString('spotifyToken') ?? '';
        }
        options.headers = {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Connection': 'Keep-Alive',
        };
        log('Using access token: $accessToken');

        method = options.method.toUpperCase();
        debugPrint("--> $method ${options.baseUrl + options.path}");
        debugPrint("queryParameters:");
        options.queryParameters.forEach((k, v) => debugPrint('$k: $v'));
        if (options.data != null) {
          log("Body: ${jsonEncode((options.data is FormData) ? options.data.toString() : options.data)}");
        }
        debugPrint("--> END ${options.method.toUpperCase()}");

        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("<-- ${response.statusCode} ${response.realUri}");
        debugPrint("Headers:");
        response.headers.forEach((k, v) => debugPrint('$k: $v'));
        debugPrint("Response Data: ${response.data}");
        debugPrint("<-- END HTTP");
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        debugPrint("<-- ${e.message} ${e.response?.realUri}");
        debugPrint(
            e.response != null ? jsonEncode(e.response?.data) : 'Unknown Error');
        debugPrint("<-- End error");

        if (e.response?.statusCode == 401) {
          log('Received 401 error. Regenerating token...');
          await MusicRepo.generateToken();
        }

        return handler.next(e);
      },
    ));

    return dio;
  }
}