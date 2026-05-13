import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ===========================================================================
// ATENÇÃO AO DESENVOLVEDOR — LEIA ANTES DE USAR ESTE SERVIÇO
// ===========================================================================
//
// O Google Sign-In NÃO FUNCIONA sem configuração Firebase.
// Para ativar a autenticação real, siga estes passos:
//
//  1. Criar um projeto no Firebase Console: https://console.firebase.google.com
//  2. Adicionar o app Android ao projeto Firebase.
//  3. Baixar google-services.json e colocar em android/app/
//  4. Obter o SHA-1 do seu keystore de debug:
//       keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
//  5. Registrar o SHA-1 no Firebase Console → Configurações do Projeto → SHA
//  6. Rodar: flutterfire configure
//  7. Importar o firebase_options.dart gerado em lib/firebase_options.dart
//  8. Habilitar "Google" em Firebase → Authentication → Sign-in methods
//
// NOTA: google_sign_in 7.x mudou a API.
//   - Não se usa mais o construtor GoogleSignIn()
//   - Use GoogleSignIn.instance + initialize() + authenticate()
//   - O accessToken agora requer authorizeScopes() separado
//
// SEM ESSAS ETAPAS, signInWithGoogle() vai retornar null.
// ===========================================================================

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _initialized = false;

  /// Stream do estado de autenticação do usuário.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Usuário atualmente autenticado (null se não logado).
  User? get currentUser => _firebaseAuth.currentUser;

  /// Retorna true se já existe uma sessão ativa.
  bool get isLoggedIn => currentUser != null;

  /// Inicializa o GoogleSignIn (chamar uma vez antes de autenticar).
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      // google_sign_in v7: deve chamar initialize() antes de authenticate()
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    } catch (e) {
      // Firebase não configurado — inicialização falha silenciosamente
      // ignore: avoid_print
      print('[AuthService] GoogleSignIn.initialize failed: $e');
    }
  }

  /// Realiza o login com Google.
  /// Retorna [User] em caso de sucesso, ou null se cancelado/não configurado.
  Future<User?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      // google_sign_in v7: authenticate() substitui signIn()
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      // Obtém apenas o idToken (accessToken requer authorizeScopes em v7)
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        // ignore: avoid_print
        print('[AuthService] idToken is null — Firebase não configurado?');
        return null;
      }

      // Cria credencial Firebase com apenas o idToken
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // Autentica no Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // ERROS COMUNS:
      // • sign_in_failed: Firebase não configurado (google-services.json faltando)
      // • network_error: Sem conexão
      // ignore: avoid_print
      print('[AuthService] FirebaseAuthException: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      // Captura qualquer outro erro inesperado (incluindo cancelamento pelo usuário)
      // ignore: avoid_print
      print('[AuthService] Unexpected error during sign-in: $e');
      return null;
    }
  }

  /// Realiza o logout do usuário.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
    } catch (e) {
      // ignore: avoid_print
      print('[AuthService] Error during sign-out: $e');
    }
  }
}
