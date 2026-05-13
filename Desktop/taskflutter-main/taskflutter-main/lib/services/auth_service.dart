import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ===========================================================================
// AuthService — Serviço de Autenticação com Google Sign-In via Firebase Auth
//
// Arquitetura (testável):
//   - GoogleSignInClient é uma abstração nossa. Ela retorna [GoogleIdTokenResult],
//     um DTO simples com apenas o idToken — sem dependências do SDK do Google.
//   - Isso permite mockar 100% sem depender dos tipos internos do google_sign_in.
//   - Para testes: AuthService.withDependencies(mockAuth, mockGsiClient)
//   - Para produção: AuthService() → usa RealGoogleSignInClient com o SDK real.
//
// Fluxo (google_sign_in v7):
//   1. GoogleSignIn.instance.initialize()
//   2. GoogleSignIn.instance.authenticate()
//   3. account.authentication.idToken
//   4. GoogleAuthProvider.credential(idToken: ...)
//   5. FirebaseAuth.signInWithCredential(credential)
// ===========================================================================

/// DTO simples com apenas o idToken retornado pelo Google.
/// Desacopla os testes dos tipos internos do google_sign_in SDK.
class GoogleIdTokenResult {
  final String? idToken;
  const GoogleIdTokenResult({required this.idToken});
}

/// Interface da camada Google Sign-In — completamente testável.
abstract class GoogleSignInClient {
  Future<void> initialize();

  /// Autentica com Google e retorna um [GoogleIdTokenResult].
  /// Lança PlatformException se o usuário cancelar.
  Future<GoogleIdTokenResult> getIdToken();

  Future<void> signOut();
}

/// Implementação real que delega para GoogleSignIn.instance (SDK v7).
class RealGoogleSignInClient implements GoogleSignInClient {
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  @override
  Future<GoogleIdTokenResult> getIdToken() async {
    final account = await GoogleSignIn.instance.authenticate();
    return GoogleIdTokenResult(idToken: account.authentication.idToken);
  }

  @override
  Future<void> signOut() => GoogleSignIn.instance.signOut();
}

// ─── AuthService ─────────────────────────────────────────────────────────────

class AuthService {
  // ── Singleton de produção ────────────────────────────────────────────────
  static final AuthService _instance = AuthService._production();
  factory AuthService() => _instance;

  // ── Dependências injetáveis ──────────────────────────────────────────────
  final FirebaseAuth _firebaseAuth;
  final GoogleSignInClient _googleSignInClient;

  /// Construtor de produção — usa instâncias reais do Firebase/Google.
  AuthService._production()
      : _firebaseAuth = FirebaseAuth.instance,
        _googleSignInClient = RealGoogleSignInClient();

  /// Construtor para testes — permite injetar mocks.
  AuthService.withDependencies(this._firebaseAuth, this._googleSignInClient);

  // ── Getters ──────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // ── Métodos ──────────────────────────────────────────────────────────────

  /// Realiza o login com Google via Firebase Auth.
  /// Retorna [User] em sucesso, null em caso de cancelamento ou erro.
  Future<User?> signInWithGoogle() async {
    try {
      // Inicializa o cliente Google (idempotente)
      await _googleSignInClient.initialize();

      // Obtém o idToken do Google
      final tokenResult = await _googleSignInClient.getIdToken();
      final idToken = tokenResult.idToken;

      if (idToken == null) {
        // ignore: avoid_print
        print('[AuthService] idToken nulo — verifique a configuração Firebase.');
        return null;
      }

      // Cria credencial Firebase
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // Autentica no Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('[AuthService] FirebaseAuthException ${e.code}: ${e.message}');
      return null;
    } catch (e) {
      // Captura PlatformException (cancelamento) e outros erros inesperados
      // ignore: avoid_print
      print('[AuthService] Erro inesperado no login: $e');
      return null;
    }
  }

  /// Realiza o logout do usuário (Firebase + Google).
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignInClient.signOut(),
      ]);
    } catch (e) {
      // ignore: avoid_print
      print('[AuthService] Erro no logout: $e');
    }
  }
}
