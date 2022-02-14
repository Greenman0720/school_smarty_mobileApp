import 'package:flutter_bloc/flutter_bloc.dart';

enum AutoNavigatorState {auto,autoSettingFan,}

class AutoNavigatorCubit extends Cubit<AutoNavigatorState> {
  AutoNavigatorCubit() : super(AutoNavigatorState.auto);

  void showAuto() => emit(AutoNavigatorState.auto);
  void showAutoSettingFan() => emit(AutoNavigatorState.autoSettingFan);

}





