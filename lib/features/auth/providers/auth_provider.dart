import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/auth_repository.dart';

const _webClientId =
    '321441200947-1lkuu9kt2na6qljhgve9o1h0srk5d0ue.apps.googleusercontent.com'; // TODO: 실제 웹 클라이언트 ID로 교체

final _googleSignIn = GoogleSignIn(
  clientId: _webClientId,
  scopes: const ['openid', 'email', 'profile'],
);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    // 앱 시작 시 저장된 JWT가 있으면 자동 로그인 상태로 복원.
    Future.microtask(_restoreSession);
    return false;
  }

  Future<void> _restoreSession() async {
    final repo = ref.read(authRepositoryProvider);
    if (await repo.hasStoredToken()) {
      state = true;
    }
  }

  /// Google 로그인 → 토큰 획득 → 서버에 교환 → JWT 저장.
  ///
  /// - 모바일: `idToken` 우선
  /// - 웹: `accessToken`만 받을 수 있음 (google_sign_in_web 한계)
  ///
  /// 사용자가 팝업을 닫은 경우 false 반환, 성공 시 true.
  Future<bool> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      return false; // 사용자 취소
    }
    final auth = await account.authentication;

    if (auth.idToken == null && auth.accessToken == null) {
      throw StateError('Google에서 토큰을 받지 못했습니다.');
    }

    final repo = ref.read(authRepositoryProvider);
    await repo.loginWithGoogle(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    state = true;
    return true;
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    await _googleSignIn.signOut();
    state = false;
  }
}

final authProvider = NotifierProvider<AuthNotifier, bool>(
  () => AuthNotifier(),
);
