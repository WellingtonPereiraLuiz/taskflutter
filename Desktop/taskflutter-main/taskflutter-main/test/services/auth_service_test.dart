// test/services/auth_service_test.dart
//
// Testes Unitários (Caixa Branca) do AuthService.
//
// Estratégia:
//   - GoogleSignInClient é uma INTERFACE NOSSA que retorna [GoogleIdTokenResult].
//   - Não há dependência dos tipos internos do google_sign_in SDK (não mockáveis).
//   - MockGoogleSignInClient é um mock puro via mocktail.
//   - AuthService.withDependencies() injeta os mocks no service.
//
// Cobertura:
//   - Sucesso no login
//   - Cancelamento pelo usuário (PlatformException)
//   - FirebaseAuthException (rede, conta duplicada)
//   - idToken nulo
//   - signOut (sucesso e falha silenciosa)
//   - isLoggedIn / currentUser

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:taskflutter/services/auth_service.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// Mock da nossa interface — sem dependências do google_sign_in SDK.
class MockGoogleSignInClient extends Mock implements GoogleSignInClient {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

// ─── Fallback ────────────────────────────────────────────────────────────────

class _FakeAuthCredential extends Fake implements AuthCredential {}

// ─── Helper ──────────────────────────────────────────────────────────────────

/// Configura o client para retornar um idToken controlado pelo teste.
void _stubGsiSuccess(
  MockGoogleSignInClient mockGsi, {
  required String? idToken,
}) {
  when(() => mockGsi.initialize()).thenAnswer((_) async {});
  when(() => mockGsi.getIdToken())
      .thenAnswer((_) async => GoogleIdTokenResult(idToken: idToken));
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignInClient mockGsi;
  late MockUser mockUser;
  late MockUserCredential mockCredential;
  late AuthService sut;

  setUpAll(() {
    registerFallbackValue(_FakeAuthCredential());
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGsi = MockGoogleSignInClient();
    mockUser = MockUser();
    mockCredential = MockUserCredential();
    sut = AuthService.withDependencies(mockAuth, mockGsi);
  });

  // ── signInWithGoogle — Sucesso ────────────────────────────────────────────

  group('signInWithGoogle — Sucesso', () {
    test(
      'retorna User quando idToken válido e Firebase aceita a credencial',
      () async {
        // Arrange
        _stubGsiSuccess(mockGsi, idToken: 'valid-id-token-123');
        when(() => mockAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockCredential);
        when(() => mockCredential.user).thenReturn(mockUser);

        // Act
        final result = await sut.signInWithGoogle();

        // Assert
        expect(result, equals(mockUser));
        verify(() => mockGsi.initialize()).called(1);
        verify(() => mockGsi.getIdToken()).called(1);
        verify(() => mockAuth.signInWithCredential(any())).called(1);
      },
    );

    test(
      'garante que initialize() é chamado ANTES de getIdToken()',
      () async {
        // Arrange
        _stubGsiSuccess(mockGsi, idToken: 'token-ordem');
        when(() => mockAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockCredential);
        when(() => mockCredential.user).thenReturn(mockUser);

        // Act
        await sut.signInWithGoogle();

        // Assert — ordem de chamada
        verifyInOrder([
          () => mockGsi.initialize(),
          () => mockGsi.getIdToken(),
        ]);
      },
    );
  });

  // ── signInWithGoogle — Cancelamento ──────────────────────────────────────

  group('signInWithGoogle — Cancelamento pelo usuário', () {
    test(
      'retorna null quando usuário cancela (PlatformException sign_in_canceled)',
      () async {
        // Arrange
        when(() => mockGsi.initialize()).thenAnswer((_) async {});
        when(() => mockGsi.getIdToken()).thenThrow(
          PlatformException(code: 'sign_in_canceled'),
        );

        // Act
        final result = await sut.signInWithGoogle();

        // Assert
        expect(result, isNull);
        verifyNever(() => mockAuth.signInWithCredential(any()));
      },
    );

    test(
      'NÃO relança PlatformException (app não crasha ao cancelar)',
      () async {
        // Arrange
        when(() => mockGsi.initialize()).thenAnswer((_) async {});
        when(() => mockGsi.getIdToken()).thenThrow(
          PlatformException(code: 'sign_in_canceled'),
        );

        // Act + Assert
        await expectLater(sut.signInWithGoogle(), completion(isNull));
      },
    );

    test(
      'retorna null quando qualquer Exception inesperada ocorre',
      () async {
        // Arrange
        when(() => mockGsi.initialize()).thenAnswer((_) async {});
        when(() => mockGsi.getIdToken())
            .thenThrow(Exception('User dismissed'));

        // Act
        final result = await sut.signInWithGoogle();

        // Assert
        expect(result, isNull);
      },
    );
  });

  // ── signInWithGoogle — Falhas Firebase ────────────────────────────────────

  group('signInWithGoogle — Falhas Firebase', () {
    test(
      'retorna null quando FirebaseAuth lança FirebaseAuthException',
      () async {
        // Arrange
        _stubGsiSuccess(mockGsi, idToken: 'valid-token');
        when(() => mockAuth.signInWithCredential(any())).thenThrow(
          FirebaseAuthException(code: 'network-request-failed'),
        );

        // Act
        final result = await sut.signInWithGoogle();

        // Assert
        expect(result, isNull);
      },
    );

    test(
      'retorna null e não chama Firebase quando idToken é null',
      () async {
        // Arrange
        _stubGsiSuccess(mockGsi, idToken: null);

        // Act
        final result = await sut.signInWithGoogle();

        // Assert
        expect(result, isNull);
        verifyNever(() => mockAuth.signInWithCredential(any()));
      },
    );

    test(
      'retorna null para account-exists-with-different-credential',
      () async {
        // Arrange
        _stubGsiSuccess(mockGsi, idToken: 'token-xyz');
        when(() => mockAuth.signInWithCredential(any())).thenThrow(
          FirebaseAuthException(
              code: 'account-exists-with-different-credential'),
        );

        // Act
        final result = await sut.signInWithGoogle();

        // Assert
        expect(result, isNull);
      },
    );
  });

  // ── signOut ───────────────────────────────────────────────────────────────

  group('signOut', () {
    test(
      'chama signOut() no FirebaseAuth e no GoogleSignInClient',
      () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        when(() => mockGsi.signOut()).thenAnswer((_) async {});

        // Act
        await sut.signOut();

        // Assert
        verify(() => mockAuth.signOut()).called(1);
        verify(() => mockGsi.signOut()).called(1);
      },
    );

    test(
      'NÃO relança exceção se signOut falhar (app não crasha)',
      () async {
        // Arrange
        when(() => mockAuth.signOut())
            .thenThrow(Exception('Falha Firebase signOut'));
        when(() => mockGsi.signOut()).thenAnswer((_) async {});

        // Act + Assert
        await expectLater(sut.signOut(), completes);
      },
    );
  });

  // ── isLoggedIn / currentUser ──────────────────────────────────────────────

  group('isLoggedIn e currentUser', () {
    test('isLoggedIn retorna false quando não há sessão', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(sut.isLoggedIn, isFalse);
    });

    test('isLoggedIn retorna true quando há sessão ativa', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      expect(sut.isLoggedIn, isTrue);
    });

    test('currentUser delega para FirebaseAuth.currentUser', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      expect(sut.currentUser, equals(mockUser));
    });

    test('currentUser retorna null quando não autenticado', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(sut.currentUser, isNull);
    });
  });
}
