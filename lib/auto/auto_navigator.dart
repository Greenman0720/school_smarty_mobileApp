import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/auto/auto_navigator_cubit.dart';

import 'package:test_new_version/auto/auto_view.dart';
import 'package:test_new_version/auto/auto_setting/auto_setting_fan_view.dart';


class AutoNavigator extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AutoNavigatorCubit(),
      child: BlocBuilder<AutoNavigatorCubit, AutoNavigatorState>(
          builder: (context, state) {
            return Navigator(
              pages: [
                //  MaterialPage(child: (HomeView())),
                if (state == AutoNavigatorState.auto)
                  MaterialPage(child: AutoView()),
                if (state == AutoNavigatorState.autoSettingFan)
                  MaterialPage(child: AutoSettingFanView()),
              ],
              onPopPage: (route, result) {
                //          context.read<HomeNavigatorCubit>().showHome();
                return route.didPop(result);
              },
            );
          }),
    );
  }
}
