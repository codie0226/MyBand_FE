import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Dio 기반 HTTP 클라이언트.
///
/// - Base URL, 타임아웃, JSON Content-Type 기본 설정
/// - 인증 인터셉터: 매 요청마다 `Authorization: Bearer {JWT}` 자동 첨부
/// - 에러 인터셉터: `DioException`을 `ApiException`/`UnauthorizedException`/`NetworkException`으로 변환
class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient(this._tokenStorage)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: AppConfig.apiTimeout,
            receiveTimeout: AppConfig.apiTimeout,
            sendTimeout: AppConfig.apiTimeout,
            contentType: 'application/json',
            responseType: ResponseType.json,
          ),
        ) {
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  Dio get dio => _dio;

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }

  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        handler.reject(_toApiException(error));
      },
    );
  }

  DioException _toApiException(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    String message = error.message ?? '알 수 없는 오류';
    String? code;

    if (data is Map<String, dynamic>) {
      message = (data['message'] as String?) ?? message;
      code = data['code'] as String?;
    }

    final ApiException apiError;
    if (status == 401) {
      apiError = UnauthorizedException(message: message);
    } else if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      apiError = const NetworkException();
    } else {
      apiError = ApiException(
        message: message,
        statusCode: status,
        code: code,
      );
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: apiError,
      message: apiError.message,
    );
  }
}
