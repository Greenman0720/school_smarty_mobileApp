import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/session_cubit.dart';

import 'package:test_new_version/auto/auto_state.dart';
import 'package:test_new_version/auto/auto_bloc.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';


import '../../constants.dart';
import '../auto_drawer.dart';
import '../auto_navigator_cubit.dart';


class AutoSettingFanView extends StatefulWidget {
  @override
  State<AutoSettingFanView> createState() => AutoSettingFanViewState();
}

class AutoSettingFanViewState extends State<AutoSettingFanView> {

  bool temSwitched = false;
  String temSwitchedString = '0';

  bool hapSwitched = false;
  String hapSwitchedString = '0';

  double autoTem = 18;
  int autoHap = 50;
  int autoFan = 0;

  String autoTemString = '18.0';
  String autoHapString = '50';
  String autoFanString = '0';
  var postJson = [];

  Future<String?> makeRequestInit() async {
    try{
      final response = await http.post(
        Uri.parse('https://52.79.62.28:1880/automode_settingFan1'),
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
        temSwitchedString =postJson[0]["fan_auto_tem_state"];
        autoTemString =postJson[0]["fan_auto_tem"];

        hapSwitchedString =postJson[0]["fan_auto_hap_state"];
        autoHapString =postJson[0]["fan_auto_hap"];

        autoFanString =postJson[0]["fan_auto_motor"];

        if(temSwitchedString == '0'){
          temSwitched = false;
        }
        if(temSwitchedString == '1'){
          temSwitched = true;
        }
        if(hapSwitchedString == '0'){
          hapSwitched = false;
        }
        if(hapSwitchedString == '1'){
          hapSwitched = true;
        }

        autoTem = double.parse(autoTemString);
        autoHap = int.parse(autoHapString);
        autoFan = int.parse(autoFanString);

      });
    } catch (err){
    }
    print('hello');
  }


  Future<String?> makeRequestAppliances() async {
    try{
       await http.post(
        Uri.parse('https://52.79.62.28:1880/automode_settingFan2'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String?>{
          'fan_auto_tem_state': temSwitchedString,
          'fan_auto_tem': autoTemString,

          'fan_auto_hap_state': hapSwitchedString,
          'fan_auto_hap': autoHapString,

          'fan_auto_motor': autoFanString,
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
    Size size = MediaQuery.of(context).size;
    final sessionCubit = context.read<SessionCubit>();
    return BlocProvider(
      create: (context) =>
          AutoBloc(
            user: sessionCubit.selectedUser ?? sessionCubit.currentUser as User,
            isCurrentUser: sessionCubit.isCurrentUserSelected,
          ),
      child: Scaffold(
          appBar: AppBar(
            title: const Text("扇風機運転設定",
              style: const TextStyle(
                fontSize: 20.0,
              ),),
            //automaticallyImplyLeading: true,
            centerTitle: true,
            elevation: 0.0,
          ),
          drawer: Drawer3(),
          body: Container(
            child: Column(
              children: [
                Expanded(child:  Container(), flex: 10,),
                Expanded(child:  body(size), flex: 87,),
                Expanded(child: footer(), flex: 10,),
                Expanded(child: Container(), flex: 3,),
              ],
            ),
          )
      ),
    );
  }

  Widget body(size){
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: loginLightBlue,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Body1(context),
    );
  }

  Widget footer(){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(right: 15),
            child: Row(
              children: [
                TextButton(onPressed: (){
                  makeRequestInit();
                  print("dd");
                }, child: Text('キャンセル',
                  style:TextStyle(
                    fontSize: 14,
                  ),)),
                TextButton(onPressed: (){
                  makeRequestAppliances();
                  BlocProvider.of<AutoNavigatorCubit>(context).showAuto();
                }, child: Text('確認',
                  style:TextStyle(
                    fontSize: 14,
                  ),)),
              ],
            )
        ),
        ],
      ),
    );
  }


  Widget Body1(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<AutoBloc, AutoState>(builder: (context, state){
      return Container(
          child: Column(
              children:
              [
                Expanded(child:  Container(), flex: 5,),
                Expanded(child:  autoTem1(), flex: 10,),
                Expanded(child:  autoTem2(size), flex: 20,),
                Expanded(child:  autoHap1(), flex: 10,),
                Expanded(child:  autoHap2(size), flex: 20,),
                Expanded(child:  autoFan1(), flex: 10,),
                Expanded(child:  autoFan2(size), flex: 20,),
                Expanded(child:  Container(), flex: 5,),
              ]
          ),
      );
    });
  }

  Widget autoTem1() {
      return Container(
          child: Row(
              children:
              [
                Expanded(child:  Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text("温度",
                    style:TextStyle(
                        fontSize: 20,
                    ),),
                ), flex: 30,),
                Expanded(child:  Container(), flex: 45,),
                Expanded(child:  Container(
                  child: Switch(
                    value: temSwitched,
                    onChanged: (value) {
                      setState(() {
                        temSwitched = value;
                        if(temSwitched == false){
                          temSwitchedString = '0';
                          print(temSwitchedString);
                        }else{
                          temSwitchedString = '1';
                          print(temSwitchedString);
                        }
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ), flex: 25,),
              ]
          ),
      );
  }

  Widget autoTem2(size) {
    return Container(
      child: Row(
          children:
          [
            Expanded(child:  Container(), flex: 15,),
            Expanded(child:  Container(
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: loginLightBlue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    height: size.height * 0.085,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(autoTemString,
                        style:TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.normal
                        ),
                      ),
                      Text(' °C',
                        style:TextStyle(
                            height: 2.5,
                            fontSize: 25,
                            fontWeight: FontWeight.normal
                        ),
                      )
                    ],
                  ),)),
            ), flex: 52,),
            Expanded(child:  Container(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    height: size.height * 0.04,
                    child: ElevatedButton(
                      child: const Icon(Icons.arrow_drop_up,),
                      onPressed: () {
                        setState(() {
                          if(autoTem <50){
                            autoTem = autoTem+0.5;
                            autoTemString = autoTem.toString();
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  SizedBox(
                    height: size.height * 0.04,
                    child: ElevatedButton(
                      child: const Icon(Icons.arrow_drop_down,),
                      onPressed: () {
                        setState(() {
                          if(autoTem >0){
                            autoTem = autoTem-0.5;
                            autoTemString = autoTem.toString();
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ) ,
            ), flex: 33,),
          ]
      ),
    );
  }

  Widget autoHap1() {
    return Container(
      child: Row(
          children:
          [
            Expanded(child:  Container(
              padding: const EdgeInsets.only(left: 20),
              child: Text("不快指数",
                style:TextStyle(
                  fontSize: 20,
                ),),
            ), flex: 30,),
            Expanded(child:  Container(), flex: 45,),
            Expanded(child:  Container(
              child: Switch(
                value: hapSwitched,
                onChanged: (value) {
                  setState(() {
                    hapSwitched = value;

                    if(hapSwitched == false){
                      hapSwitchedString = '0';
                      print(hapSwitchedString);
                    }else{
                      hapSwitchedString = '1';
                      print(hapSwitchedString);
                    }
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
            ), flex: 25,),
          ]
      ),
    );
  }

  Widget autoHap2(size) {
    return Container(
      child: Row(
          children:
          [
            Expanded(child:  Container(), flex: 15,),
            Expanded(child:  Container(
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: loginLightBlue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    height: size.height * 0.085,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('   $autoHapString',
                          style:TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                        Text(' %',
                          style:TextStyle(
                              height: 2.5,
                              fontSize: 25,
                              fontWeight: FontWeight.normal
                          ),
                        )
                      ],
                    ),)),
            ), flex: 52,),
            Expanded(child:  Container(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    height: size.height * 0.04,
                    child: ElevatedButton(
                      child: const Icon(Icons.arrow_drop_up,),
                      onPressed: () {
                        setState(() {
                          if(autoHap <99){
                            autoHap++;
                            autoHapString = autoHap.toString();
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  SizedBox(
                    height: size.height * 0.04,
                    child: ElevatedButton(
                      child: const Icon(Icons.arrow_drop_down,),
                      onPressed: () {
                        setState(() {
                          if(autoHap >10){
                            autoHap--;
                            autoHapString = autoHap.toString();
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ) ,
            ), flex: 33,),
          ]
      ),
    );
  }





  Widget autoFan1() {
    return Container(
      child: Row(
          children:
          [
            Expanded(child:  Container(
              padding: const EdgeInsets.only(left: 20),
              child: Text("扇風機",
                style:TextStyle(
                  fontSize: 20,
                ),),
            ), flex: 30,),
            Expanded(child:  Container(), flex: 45,),
            Expanded(child:  Container(), flex: 25,),
          ]
      ),
    );
  }

  Widget autoFan2(size) {
    return Container(
      child: Row(
          children:
          [
            Expanded(child:  Container(), flex: 15,),
            Expanded(child:  Container(
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: loginLightBlue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    height: size.height * 0.085,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(autoFanString,
                          style:TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.normal
                          ),
                        ),

                      ],
                    ),)),
            ), flex: 52,),
            Expanded(child:  Container(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    height: size.height * 0.04,
                    child: ElevatedButton(
                      child: const Icon(Icons.arrow_drop_up,),
                      onPressed: () {
                        setState(() {
                          if(autoFan <3){
                            autoFan++;
                            autoFanString = autoFan.toString();
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  SizedBox(
                    height: size.height * 0.04,
                    child: ElevatedButton(
                      child: const Icon(Icons.arrow_drop_down,),
                      onPressed: () {
                        setState(() {
                          if(autoFan >0){
                            autoFan--;
                            autoFanString = autoFan.toString();
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ) ,
            ), flex: 33,),
          ]
      ),
    );
  }


}

