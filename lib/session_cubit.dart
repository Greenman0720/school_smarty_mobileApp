import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/auth/auth_credentials.dart';
import 'package:test_new_version/auth/auth_repository.dart';
import 'package:test_new_version/data_repository.dart';
import 'package:test_new_version/session_state.dart';

import 'models/User.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepo;
  final DataRepository dataRepo;

  User? get currentUser => (state as Authenticated).user;
  User? get selectedUser => (state as Authenticated).selectedUser;
  bool get isCurrentUserSelected =>
      selectedUser == null || currentUser!.id == selectedUser!.id;



  SessionCubit({
    required this.authRepo,
    required this.dataRepo,
  }) : super(UnknownSessionState()) {
    attemptAutoLogin();
  }

  void attemptAutoLogin() async {
    try {
      final userId = await authRepo.attemptAutoLogin();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      User? user = await dataRepo.getUserById(userId);
      if (user == null) {
        user = await dataRepo.createUser(
          userId: userId,
          username: 'User-${UUID()}',
        );
      }
      emit(Authenticated(user: user));
    } on Exception {
      emit(Unauthenticated());
    }
  }

  void showAuth() => emit(Unauthenticated());

  void showSession(AuthCredentials credentials) async {
    try {
      User? user = await dataRepo.getUserById(credentials.userId as String);

      if (user == null) {
        user = await dataRepo.createUser(
          userId: credentials.userId,
          username: credentials.username,
          email: credentials.email,
        );
      }

      emit(Authenticated(user: user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void signOut() {
    authRepo.signOut();
    emit(Unauthenticated());
  }
}
