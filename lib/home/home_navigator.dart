import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/auto/auto_navigator.dart';
import 'package:test_new_version/billing/billing_navigator.dart';
import 'package:test_new_version/monitor/monitor_view.dart';
import 'package:test_new_version/home/home_navigator_cubit.dart';
import 'package:test_new_version/home/home_view.dart';

class HomeNavigator extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeNavigatorCubit(),
      child: BlocBuilder<HomeNavigatorCubit, HomeNavigatorState>(
          builder: (context, state) {
        return Navigator(
          pages: [
            if (state == HomeNavigatorState.monitor)
              MaterialPage(child: MonitorView()),
            if (state == HomeNavigatorState.billing)
              MaterialPage(child: BillingNavigator()),
            if (state == HomeNavigatorState.home)
              MaterialPage(child: HomeView()),
            if (state == HomeNavigatorState.auto)
              MaterialPage(child: AutoNavigator()),
          ],
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        );
      }),
    );
  }
}
