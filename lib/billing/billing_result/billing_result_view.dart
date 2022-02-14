import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/session_cubit.dart';

import 'package:test_new_version/billing/billing_state.dart';
import 'package:test_new_version/billing/billing_bloc.dart';

import '../../constants.dart';
import '../billing_drawer.dart';
import '../billing_view.dart';

class BillingResultView extends StatefulWidget {
  @override
  State<BillingResultView> createState() => _BillingResultViewState();
}

class _BillingResultViewState extends State<BillingResultView> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String appToken = '';

  String get startYearDate => BillingViewState.startYearDate;
  String get startMonthDate => BillingViewState.startMonthDate;
  String get startDayDate => BillingViewState.startDayDate;
  String get endYearDate => BillingViewState.endYearDate;
  String get endMonthDate => BillingViewState.endMonthDate;
  String get endDayDate => BillingViewState.endDayDate;
  String get realPeriod => BillingViewState.realPeriod;

  String? startDateString = '';
  String? endDateString= '';

  double totalTemTime = 0;
  double totalTemState = 0;
  double totalFanTime = 0;
  double totalFanCurrent1 = 0;
  double totalFanCurrent2 = 0;
  double totalFanCurrent3 = 0;

  double totalTemSumPower = 0;
  double totalTemPrice = 0;
  double totalFanSumPower = 0;
  double totalFanPrice = 0;

  double totalAllPower = 0;
  double totalAllPrice = 0;


  String totalTemTimeString = '';
  String totalTemStateString = '';
  String totalFanTimeString = '';
  String totalFanCurrent1String = '';
  String totalFanCurrent2String = '';
  String totalFanCurrent3String = '';

  String totalTemSumPowerString = '';
  String totalTemPriceString = '';
  String totalFanSumPowerString = '';
  String totalFanPriceString = '';

  String totalAllPowerString = '';
  String totalAllPriceString = '';

  var postJson = [];

  Future<String?> makeRequest() async {
    try{
      final response = await http.post(
        Uri.parse('https://52.79.62.28:1880/calculate_date'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String?>{
          'startDate': startDateString,
          'endDate': endDateString,
          'token':appToken,
        }),
      );
      final jsonData = jsonDecode(response.body) as List;
      setState(() {
        postJson = jsonData;
        totalTemTimeString =postJson[0]["totalTemTime"];
        totalTemStateString =postJson[0]["totalTemState"];
        totalFanTimeString =postJson[0]["totalFanTime"];
        totalFanCurrent1String =postJson[0]["totalFanCurrent1"];
        totalFanCurrent2String =postJson[0]["totalFanCurrent2"];
        totalFanCurrent3String =postJson[0]["totalFanCurrent3"];

        totalTemTime = double.parse(totalTemTimeString);
        totalTemState = double.parse(totalTemStateString);
        totalFanTime = double.parse(totalFanTimeString);
        totalFanCurrent1 = double.parse(totalFanCurrent1String);
        totalFanCurrent2 = double.parse(totalFanCurrent2String);
        totalFanCurrent3 = double.parse(totalFanCurrent3String);

        totalTemSumPower = 0.275/60*totalTemState;
        totalTemSumPowerString = totalTemSumPower.toString();
        totalTemPrice = totalTemSumPower / 1000 * 27;

        totalFanSumPower = (37.4/60*totalFanCurrent1)+(45.1/60*totalFanCurrent2)+(56.1/60*totalFanCurrent3);
        totalFanPrice = totalFanSumPower / 1000 * 27;

        totalAllPower = totalTemSumPower + totalFanSumPower;
        totalAllPrice = totalTemPrice + totalFanPrice;


      });
      //    print(response.body);
    } catch (err){
    }
  }

  String changeHour(double Time, String TimeString){
      if(Time == 0){
        TimeString = '0分';
      }else if(Time < 60 && Time > 0){
      TimeString = TimeString+'分';
    }else if(Time < 1440 && Time >= 60){
      int Hour = Time ~/ 60;
      double Min =  Time % 60;
      TimeString = Hour.toString() + '時間' + Min.toStringAsFixed(0) + '分';
    }else if(Time < 43200 && Time >= 1440){
      int Day =  Time ~/ 1440;
      double DayRe = Time % 1440;
      int Hour = DayRe ~/ 60;
      double Min =  DayRe % 60;
      TimeString = Day.toString() +  '日'+ Hour.toString() + '時間' + Min.toStringAsFixed(0) + '分';
    }
    return TimeString;
  }

  String changePower(double Power, String PowerString){
    if(Power == 0){
      PowerString = Power.toString() + 'wh';
    }else if(Power < 1 && Power > 0){
      PowerString = Power.toStringAsFixed(3) + 'wh';
    }else if(Power < 1000 && Power >= 1){
      PowerString = Power.toStringAsFixed(3) + 'wh';
    }else if(Power >= 1000){
      Power = Power/1000;
      PowerString = Power.toStringAsFixed(3) + 'Kwh';
    }
    return PowerString;
  }

  String changePrice(double Price, String PriceString){
    if(Price == 0){
      PriceString = '0円';
    }else {
      PriceString = Price.toStringAsFixed(3) + '円';
    }
    return PriceString;
  }



  @override
  void initState() {
    _firebaseMessaging.getToken().then((token) => {
      //print(token)
      appToken = token!
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      makeRequest();
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final sessionCubit = context.read<SessionCubit>();
    return BlocProvider(
      create: (context) =>
          BillingBloc(
            user: sessionCubit.selectedUser ?? sessionCubit.currentUser as User,
            isCurrentUser: sessionCubit.isCurrentUserSelected,
          ),
      child: Scaffold(
          appBar: AppBar(
            title: const Text("使用量",
              style: const TextStyle(
                fontSize: 20.0,
              ),),
            //automaticallyImplyLeading: true,
            centerTitle: true,
            elevation: 0.0,
          ),
          drawer: Drawer2(),
          body: Column(
            children: [
              Expanded(child: Container(), flex:7,),
              Expanded(child: Container(),flex: 3,),
              Expanded(child: Container(child:body(size),), flex: 77,),
              Expanded(child: Container(),flex: 8,),
              Expanded(child: Container(), flex: 5,),
            ],
          ),
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
      child: Column(
        children: [
          Container(height: 10,),
          Body0(context),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Body1(context)
          )
        ],
      ),
    );
  }



  Widget Body0(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(builder: (context, state){
      startDateString = state.startFullDate as String;
      endDateString = state.endFullDate as String;

      String startYear = startDateString!.substring(0,4);
      String startMonth = startDateString!.substring(4,6);
      String startDay = startDateString!.substring(6,8);
      String endYear = endDateString!.substring(0,4);
      String endMonth =endDateString!.substring(4,6);
      String endDay =  endDateString!.substring(6,8);

      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 4.0, color: loginLightBlue),
          ),
        ),
        child: Column(
          children: [
            Row(
                children:
                [
                  Expanded(child: Container(), flex:5,),
                  Expanded(child: Container(
                    child: Text(
                        '$startYear年 $startMonth月 $startDay日'
                             ' ~ '
                            '$endYear年 $endMonth月 $endDay日'),
                  ), flex:90,),
                  Expanded(child: Container(), flex:5,),
                ]
            ),
            Container(
              height: 10,
            )
          ],
        ),
      );
    });
  }

  Widget Body1(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(builder: (context, state){
      startDateString = state.startFullDate as String;
      endDateString = state.endFullDate as String;
      return Container(
        child: Column(
            children:
            [
              DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Expanded(child: Text("名前", textAlign:TextAlign.center)),
                  ),
                  DataColumn(
                    label: Expanded(child: Text("使用時間", textAlign:TextAlign.center)),
                  ),
                  DataColumn(
                    label: Expanded(child: Text("消費電力", textAlign:TextAlign.center)),
                  ),
                  DataColumn(
                    label: Expanded(child: Text(" 料金", textAlign:TextAlign.center)),
                  ),
                ],
                rows: <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Center(child: Text('温湿度計'))),
                      DataCell(Center(child: Text(changeHour(totalTemTime,totalTemTimeString)),)),
                      DataCell(Center(child: Text(changePower(totalTemSumPower, totalTemSumPowerString)),)),
                      DataCell(Center(child:Text(changePrice(totalTemPrice,totalTemPriceString)),)),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Center(child: Text('扇風機'))),
                      DataCell(Center(child: Text(changeHour(totalFanTime,totalFanTimeString)),)),
                      DataCell(Center(child: Text(changePower(totalFanSumPower, totalFanSumPowerString)),)),
                      DataCell(Center(child:Text(changePrice(totalFanPrice,totalFanPriceString)),)),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Center(child: Text('冷蔵庫'))),
                      DataCell(Center(child: Text('0分'),)),
                      DataCell(Center(child: Text('0.0wh'),)),
                      DataCell(Center(child:Text('0円'),)),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Center(child: Text('テレビ'))),
                      DataCell(Center(child: Text('0分'),)),
                      DataCell(Center(child: Text('0.0wh'),)),
                      DataCell(Center(child:Text('0円'),)),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Center(child: Text('総合'))),
                      DataCell(Center(child: Text(''),)),
                      DataCell(Center(child: Text(changePower(totalAllPower, totalAllPowerString)),)),
                      DataCell(Center(child:Text(changePrice(totalAllPrice, totalAllPriceString)),)),
                    ],
                  ),
                ],
              ),
            ]
        ),
      );
    });
  }
}
