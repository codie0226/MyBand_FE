/// 앱 전역 설정.
///
/// `useMock`이 true이면 Repository가 Mock 데이터를 반환하고,
/// false이면 실제 BE 서버(`apiBaseUrl`)에 요청한다.
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:3000';

  /// 개발 환경에서 BE 미실행 시 Mock 데이터 사용 여부.
  /// 운영 빌드에서는 반드시 false로 둬야 한다.
  static const bool useMock = false;

  /// API 호출 타임아웃.
  static const Duration apiTimeout = Duration(seconds: 15);
}
