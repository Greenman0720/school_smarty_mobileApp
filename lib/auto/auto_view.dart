import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/session_cubit.dart';

import 'package:test_new_version/auto/auto_state.dart';
import 'package:test_new_version/auto/auto_bloc.dart';
import 'package:test_new_version/auto/auto_navigator_cubit.dart';

import 'auto_drawer.dart';

class AutoView extends StatefulWidget {
  @override
  State<AutoView> createState() => AutoViewState();
}

class AutoViewState extends State<AutoView> {



  bool fanSwitched = false;
  String fanSwitchedString = 'off';

  var postJson = [];

  Future<String?> makeRequestInit() async {
    try{
      final response = await http.post(
        Uri.parse('https://52.79.62.28:1880/automode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String?>{
          'appliances': 'appliances',
        }),
      );
      final jsonData = jsonDecode(response.body) as List;
      setState(() {
        postJson = jsonData;
        fanSwitchedString =postJson[0]["fanAutoMode"];
        if(fanSwitchedString == '0'){
          fanSwitched = false;
        }
        if(fanSwitchedString == '1'){
          fanSwitched = true;
        }
      });
    } catch (err){
    }
  }


  Future<String?> makeRequestAppliances(String appliances,String mode) async {
    try{
      await http.post(
        Uri.parse('https://52.79.62.28:1880/automode_appliances'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String?>{
          'appliances': appliances,
          'auto_mode': mode,
        }),
      );
    } catch (err){
    }
  }

  @override
  void initState() {
    makeRequestInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sessionCubit = context.read<SessionCubit>();
    return BlocProvider(
      create: (context) =>
          AutoBloc(
            user: sessionCubit.selectedUser ?? sessionCubit.currentUser as User,
            isCurrentUser: sessionCubit.isCurrentUserSelected,
          ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("自動運転設定",
            style: const TextStyle(
              fontSize: 20.0,
            ),),
          //automaticallyImplyLeading: true,
          centerTitle: true,
          elevation: 0.0,
        ),
        drawer: Drawer3(),
        body: Body1(context),
      ),
    );
  }


  Widget Body1(BuildContext context){
    return BlocBuilder<AutoBloc, AutoState>(builder: (context, state) {
      return Container(
        // margin: const EdgeInsets.fromLTRB(50, 150, 50, 150),
        child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Card(
                  child: ListTile(
                    title: Text("温湿度計"),
                    trailing: Wrap(
                      children: <Widget>[
                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text("扇風機"),
                    trailing: Wrap(
                      children: <Widget>[
                        Switch(
                          value: fanSwitched,
                          onChanged: (value) {
                            setState(() {
                              fanSwitched = value;

                              if(fanSwitched == false){
                                fanSwitchedString = '0';
                                print(fanSwitchedString);
                                makeRequestAppliances('fan',fanSwitchedString);
                              }else{
                                fanSwitchedString = '1';
                                print(fanSwitchedString);
                                makeRequestAppliances('fan',fanSwitchedString);
                              }
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                        IconButton(
                          icon: Icon(Icons.settings_rounded),
                          onPressed: () {
                            BlocProvider.of<AutoNavigatorCubit>(context).showAutoSettingFan();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text("冷蔵庫"),
                    trailing: Wrap(
                      children: <Widget>[

                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text("テレビ"),
                    trailing: Wrap(
                      children: <Widget>[

                      ],
                    ),
                  ),
                ),

              ],
            )),
      );
    });
  }


}

