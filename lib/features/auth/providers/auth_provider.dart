import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

final authRepositoryProvider = Provider<BaseAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.value;
});

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    final authRepo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => authRepo.signInAnonymously());
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    final authRepo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(
      () => authRepo.signInWithEmailAndPassword(email, password),
    );
  }

  Future<void> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncValue.loading();
    final authRepo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(
      () => authRepo.registerWithEmailAndPassword(email, password, displayName),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final authRepo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => authRepo.signOut());
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
