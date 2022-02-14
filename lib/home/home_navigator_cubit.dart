import 'package:flutter_bloc/flutter_bloc.dart';

enum HomeNavigatorState { home, monitor, billing, auto}

class HomeNavigatorCubit extends Cubit<HomeNavigatorState> {
  HomeNavigatorCubit() : super(HomeNavigatorState.home);

  void showHome() => emit(HomeNavigatorState.home);
  void showMonitor() => emit(HomeNavigatorState.monitor);
  void showBilling() => emit(HomeNavigatorState.billing);
  void showAuto() => emit(HomeNavigatorState.auto);

}
