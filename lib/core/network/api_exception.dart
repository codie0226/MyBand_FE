/// API 호출 중 발생한 모든 에러를 통합하는 예외 클래스.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() =>
      'ApiException(status: $statusCode, code: $code, message: $message)';
}

/// 401 Unauthorized — 토큰 만료/무효 시 자동 로그아웃 트리거에 사용.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = '인증이 필요합니다.'})
      : super(statusCode: 401, code: 'UNAUTHORIZED');
}

/// 네트워크 연결 실패.
class NetworkException extends ApiException {
  const NetworkException({super.message = '네트워크에 연결할 수 없습니다.'})
      : super(code: 'NETWORK');
}
