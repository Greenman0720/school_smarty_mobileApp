import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/auth/auth_credentials.dart';
import 'package:test_new_version/session_cubit.dart';

enum AuthState { login, signUp, confirmSignUp }

class AuthCubit extends Cubit<AuthState> {
  final SessionCubit? sessionCubit;

  AuthCubit({this.sessionCubit}) : super(AuthState.login);

  AuthCredentials? credentials;

  void showLogin() => emit(AuthState.login);
  void showSignUp() => emit(AuthState.signUp);
  void showConfirmSignUp({
    required String username,
    String? email,
    String? password,
  }) {
    credentials = AuthCredentials(
      username: username,
      email: email,
      password: password,
    );
    emit(AuthState.confirmSignUp);
  }

  void launchSession(AuthCredentials credentials) =>
      sessionCubit!.showSession(credentials);
}
