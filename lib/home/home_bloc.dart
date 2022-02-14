import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/home/home_event.dart';
import 'package:test_new_version/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required User user, required bool isCurrentUser})
      : super(HomeState(user: user, isCurrentUser: isCurrentUser));
}
