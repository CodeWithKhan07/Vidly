import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../core/error/app_exceptions.dart';
import '../models/media_model.dart';

class VideoRepository {
  late final Dio _dio;

  VideoRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://snap-video3.p.rapidapi.com",
        headers: {
          'x-rapidapi-key': dotenv.get("API_KEY"),
          'x-rapidapi-host': 'snap-video3.p.rapidapi.com',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }

  Future<MediaModel> fetchVideoInfo(String url) async {
    try {
      final response = await _dio.post(
        "/download",
        data: {"url": url},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );
      if (response.data == null) {
        throw ServerException("Empty response from server.");
      }
      if (response.data is! Map<String, dynamic>) {
        log("Unexpected response format: ${response.data.runtimeType}");
        throw ServerException("Unexpected data format received from server.");
      }
      final model = MediaModel.fromJson(response.data as Map<String, dynamic>);
      if (model.error == true) {
        throw ServerException(
          "The API could not process this link. It might be private or invalid.",
        );
      }

      return model;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final errorMsg = e.response?.data['message'] ?? e.message;
        throw ServerException(errorMsg);
      }
      throw ExceptionHandler.handleDioError(e);
    } catch (e) {
      log("Repository Error: $e");
      throw ServerException("Unexpected error: ${e.toString()}");
    }
  }

  Future<Response> downloadFile({
    required String url,
    required String savePath,
    required Function(int, int) onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      log("Starting download from: $url");
      return await Dio().download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ServerException("Download failed: ${e.toString()}");
    }
  }
}
