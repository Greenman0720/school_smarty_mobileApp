import 'package:alan_voice/alan_voice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:test_new_version/home/home_navigator_cubit.dart';

import '../session_cubit.dart';
import 'auto_bloc.dart';
import 'auto_navigator_cubit.dart';
import 'auto_state.dart';



class Drawer3 extends StatelessWidget {
  Drawer3({Key? key}) : super(key: key);

  final MqttServerClient client =
  MqttServerClient('a28gkg1ipmelf1-ats.iot.ap-northeast-2.amazonaws.com', '');

  _disconncet() {
    client.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoBloc, AutoState>(builder: (context, state) {
      return Drawer(
        child: Column(
          children: [
            Expanded(
              flex: 0,
              child: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.85,
                child: UserAccountsDrawerHeader(
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/smarty1.PNG'),
                    backgroundColor: Colors.white,
                  ),
                  accountName: Text(state.username as String),
                  accountEmail: Text('state.email as String'),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: ListView(children: [
                ListTile(
                    leading: const Icon(Icons.home,
                      color: Color(0xFF616161),
                    ),
                    title: const Text('ホーム',
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                    onTap: () {
                      _disconncet();
                      BlocProvider.of<HomeNavigatorCubit>(context).showHome();
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.monitor,
                      color: Color(0xFF616161),
                    ),
                    title: const Text('モニタリング',
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),),
                    onTap: () {
                      _disconncet();
                      AlanVoice.removeButton();
                      BlocProvider.of<HomeNavigatorCubit>(context).showMonitor();
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.payments_outlined,
                      color: Color(0xFF616161),
                    ),
                    title: const Text('電気使用量と請求額',
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),),
                    onTap: () {
                      _disconncet();
                      AlanVoice.removeButton();
                      BlocProvider.of<HomeNavigatorCubit>(context).showBilling();
                    }
                ),
                ListTile(
                  leading: const Icon(Icons.psychology,
                    color: Color(0xFF616161),
                  ),
                  title: const Text('自動運転設定',
                    style: const TextStyle(
                      fontSize: 13.0,
                    ),
                  ),
                  onTap: () {
                    _disconncet();
                    AlanVoice.removeButton();
                    BlocProvider.of<AutoNavigatorCubit>(context).showAuto();
                  },
                ),
                ListTile(
                    leading: const Icon(Icons.logout,
                      color: Color(0xFF616161),
                    ),
                    title: const Text('ログアウト',
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),),
                    onTap: () {
                      _disconncet();
                      AlanVoice.removeButton();
                      BlocProvider.of<SessionCubit>(context).signOut();
                    }
                ),
              ]),
            ),
          ],
        ),
      );
    });
  }
}
