import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'billing_navigator_cubit.dart';
import 'billing_result/billing_result_view.dart';
import 'package:test_new_version/billing/billing_view.dart';

class BillingNavigator extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BillingNavigatorCubit(),
      child: BlocBuilder<BillingNavigatorCubit, BillingNavigatorState>(
          builder: (context, state) {
            return Navigator(
              pages: [
                //  MaterialPage(child: (HomeView())),
                if (state == BillingNavigatorState.billing)
                  MaterialPage(child: BillingView()),
                if (state == BillingNavigatorState.billingResult)
                  MaterialPage(child: BillingResultView()),
              ],
              onPopPage: (route, result) {
                return route.didPop(result);
              },
            );
          }),
    );
  }
}
