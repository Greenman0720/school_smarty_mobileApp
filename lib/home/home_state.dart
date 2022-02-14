import 'package:test_new_version/auth/form_submission_status.dart';
import 'package:test_new_version/models/User.dart';

class HomeState {
  final User user;
  final bool isCurrentUser;
  final String? avatarPath;
  final String? userDescription;

  String? get username => user.username;
  String? get email => user.email;

  final FormSubmissionStatus formStatus;

  HomeState({
    required User user,
    required bool isCurrentUser,
    String? avatarPath,
    String? userDescription,
    this.formStatus = const InitialFormStatus(),
  })  : this.user = user,
        this.isCurrentUser = isCurrentUser,
        this.avatarPath = avatarPath,
        this.userDescription = userDescription ?? user.description;

  HomeState copyWith({
    User? user,
    String? avatarPath,
    String? userDescription,
    FormSubmissionStatus? formStatus,
  }) {
    return HomeState(
      user: user ?? this.user,
      isCurrentUser: this.isCurrentUser,
      avatarPath: avatarPath ?? this.avatarPath,
      userDescription: userDescription ?? this.userDescription,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
