import 'package:test_new_version/models/User.dart';

class AutoState {
  final User user;
  final bool isCurrentUser;

  String? get username => user.username;
  String? get email => user.email;

  AutoState({
    required User user,
    required bool isCurrentUser,
  })  : this.user = user,
        this.isCurrentUser = isCurrentUser;


  AutoState copyWith({
    User? user,
  }) {
    return AutoState(
      user: user ?? this.user,
      isCurrentUser:  this.isCurrentUser,
    );
  }
}
