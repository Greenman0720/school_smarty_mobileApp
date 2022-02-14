import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/auth/auth_cubit.dart';
import 'package:test_new_version/auth/auth_navigator.dart';
import 'package:test_new_version/loading_view.dart';
import 'package:test_new_version/session_cubit.dart';
import 'package:test_new_version/session_state.dart';

import 'home/home_navigator.dart';


class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(builder: (context, state) {
      return Navigator(
        pages: [
          // Show loading screen
          if (state is UnknownSessionState) MaterialPage(child: LoadingView()),

          // Show auth flow
          if (state is Unauthenticated)
            MaterialPage(
              child: BlocProvider(
                create: (context) =>
                    AuthCubit(sessionCubit: context.read<SessionCubit>()),
                child: AuthNavigator(),
              ),
            ),

          // Show session flow
          if (state is Authenticated)
            MaterialPage(child: HomeNavigator()
            )
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
