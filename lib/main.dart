import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/amplifyconfiguration.dart';
import 'package:test_new_version/app_navigator.dart';
import 'package:test_new_version/auth/auth_repository.dart';
import 'package:test_new_version/data_repository.dart';
import 'package:test_new_version/loading_view.dart';
import 'package:test_new_version/models/ModelProvider.dart';
import 'package:test_new_version/session_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  HttpOverrides.global = new DevHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('ja'),
        ],
        locale: const Locale('ja'),
        home: _isAmplifyConfigured
            ? MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (context) => AuthRepository()),
            RepositoryProvider(create: (context) => DataRepository())
          ],
          child: BlocProvider(
            create: (context) => SessionCubit(
              authRepo: context.read<AuthRepository>(),
              dataRepo: context.read<DataRepository>(),
            ),
            child: AppNavigator(),
          ),
        )
            : LoadingView());
  }

  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyDataStore(modelProvider: ModelProvider.instance),
        AmplifyAPI(),
      ]);

      await Amplify.configure(amplifyconfig);

      setState(() => _isAmplifyConfigured = true);
    } catch (e) {
      print(e);
    }
  }
}
