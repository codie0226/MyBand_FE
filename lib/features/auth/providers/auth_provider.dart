import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _webClientId =
    '321441200947-1lkuu9kt2na6qljhgve9o1h0srk5d0ue.apps.googleusercontent.com'; // TODO: 실제 웹 클라이언트 ID로 교체

final _googleSignIn = GoogleSignIn(clientId: _webClientId);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    state = account != null;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    state = false;
  }
}

final authProvider = NotifierProvider<AuthNotifier, bool>(
  () => AuthNotifier(),
);
