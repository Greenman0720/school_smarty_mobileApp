import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/auto/auto_event.dart';
import 'package:test_new_version/auto/auto_state.dart';


class AutoBloc extends Bloc<AutoEvent, AutoState> {
  AutoBloc({required User user, required bool isCurrentUser})
      : super(AutoState(user: user, isCurrentUser: isCurrentUser));

  @override
  Stream<AutoState> mapEventToState(AutoEvent event) async* {

  }
}
