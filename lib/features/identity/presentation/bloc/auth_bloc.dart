import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/token_storage.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login _login;
  final Register _register;
  final Logout _logout;
  final GetProfile _getProfile;
  final TokenStorage _tokenStorage;

  AuthBloc({
    required Login login,
    required Register register,
    required Logout logout,
    required GetProfile getProfile,
    required TokenStorage tokenStorage,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _getProfile = getProfile,
        _tokenStorage = tokenStorage,
        super(const AuthInitial()) {
    on<CheckSession>(_onCheckSession);
    on<AuthLogin>(_onLogin);
    on<AuthRegister>(_onRegister);
    on<AuthLogout>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  Future<void> _onCheckSession(
    CheckSession event,
    Emitter<AuthState> emit,
  ) async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      emit(const Unauthenticated());
      return;
    }
    final result = await _getProfile(const NoParams());
    result.fold(
      (_) => emit(const Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final loginResult = await _login(
      LoginParams(email: event.email, password: event.password),
    );
    await loginResult.fold(
      (failure) async => emit(AuthError(failure)),
      (_) async {
        final profileResult = await _getProfile(const NoParams());
        profileResult.fold(
          (failure) => emit(AuthError(failure)),
          (user) => emit(Authenticated(user)),
        );
      },
    );
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _register(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(RegisterSuccess(user.email)),
    );
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    final refreshToken = await _tokenStorage.getRefreshToken() ?? '';
    await _logout(LogoutParams(refreshToken: refreshToken));
    emit(const Unauthenticated());
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _tokenStorage.clearTokens();
    emit(const Unauthenticated());
  }
}
