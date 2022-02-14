import 'dart:async';

import 'package:alan_voice/alan_voice.dart';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:test_new_version/home/home_drawer.dart';

import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/session_cubit.dart';
import 'package:test_new_version/home/home_bloc.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:tap_debouncer/tap_debouncer.dart';

import '../constants.dart';
import 'home_navigator_cubit.dart';


class HomeView extends StatefulWidget {

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final dropdownState = GlobalKey<FormFieldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  void sendData(){
    var params = jsonEncode({"temperature":device_temTemperature});
    AlanVoice.callProjectApi("script::getCount",params);
  }

  void sendData2(){
    var params2 = jsonEncode({"order":1});
    AlanVoice.callProjectApi("script::getCount2",params2);
  }

  _HomeViewState() {
    /// Init Alan Button with project key from Alan Studio
    AlanVoice.addButton("bf3199c1d1ccec825a594b64d1f84aba2e956eca572e1d8b807a3e2338fdd0dc/testing",
    buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.onCommand.add((command) => handleCommand(command.data));

  }

  void handleCommand(Map<String, dynamic> command) {
    switch(command["command"]){
      case "one":
        oneCounter();
        _fanCounterString = _fanCounter.toString();
        publishFanString(_fanCounterString);
        AlanVoice.deactivate();
        break;
      case "two":
       twoCounter();
       _fanCounterString = _fanCounter.toString();
       publishFanString(_fanCounterString);
        AlanVoice.deactivate();
        break;
      case "three":
        threeCounter();
        _fanCounterString = _fanCounter.toString();
        publishFanString(_fanCounterString);
        AlanVoice.deactivate();
        break;
      case "temperature":
        setState(() {
          Future.delayed(const Duration(milliseconds: 1000), () {
            sendData();
            sendData2();
          });
          Future.delayed(const Duration(milliseconds: 6000), () {
            AlanVoice.deactivate();
          });

           });
        break;
      case "stop":
        zeroCounter();
        _fanCounterString = _fanCounter.toString();
        publishFanString(_fanCounterString);
        AlanVoice.deactivate();
        break;
      default:
        debugPrint("unknown command");
    }
  }

  void zeroCounter() {
    _fanCounter = 0;
  }

  void oneCounter() {
    _fanCounter = 1;
  }

  void twoCounter() {
    _fanCounter = 2;
  }

  void threeCounter() {
    _fanCounter = 3;
  }

  int device_connection = 0;
  int device_battery = 0;
  int device_autoMode = 0;
  int device_fanPower = 0;

  double device_temHappy =0;
  String device_temTemperature = "00.0";
  String device_temHumidity = "00";


  int device_fanMotor = 0;


  List<String> _furniture = ["温湿度計", "扇風機"];
  String? _selectedFurniture;
  String realFurniture = "温湿度計";
  final controller = StreamController<String>();


  int _fanCounter = 0;
  String _fanCounterString = '0';

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  String statusText = "";
  bool isConnected = false;
  String idTextController = "seon";

  final MqttServerClient client =
  MqttServerClient('a28gkg1ipmelf1-ats.iot.ap-northeast-2.amazonaws.com', '');
  String topicSubscribe = 'school_project/flutter/test_new_version/homepage/subscribe';
  String topicPublish = 'school_project/flutter/test_new_version/homepage/publish';
  String topicFanPublish = 'school_project/flutter/test_new_version/homepage/publish/fanmotor';

  @override
  void initState() {
    setStatus("接続中");
    _firebaseMessaging.getToken().then((token) => print(token));
    super.initState();
    Future.delayed(const Duration(milliseconds: 850), () {
      _disconncet();
      _connect();
      super.initState();
    });


  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final sessionCubit = context.read<SessionCubit>();

    return BlocProvider(
      create: (context) =>
          HomeBloc(
            user: sessionCubit.selectedUser ?? sessionCubit.currentUser as User,
            isCurrentUser: sessionCubit.isCurrentUserSelected,
          ),

      child: Scaffold(
        appBar: AppBar(
          title: const Text("ホーム",
            style: const TextStyle(
              fontSize: 20.0,
            ),),
          //automaticallyImplyLeading: true,
          centerTitle: true,
          elevation: 0.0,
        ),
        drawer: Drawer1(),
        body: Column(
          children: [
            Expanded(child: Container(), flex: 10,),
            Expanded(child: Container(child:body(size),), flex: 77,),
            Expanded(child: Container(), flex: 8,),
            Expanded(child: Container(child: footer(),), flex: 5,),
          ],
        ),
      ),
    );
  }

  Widget body(size) {
    return  Container(
      child: Row(children: [
        Expanded(child: Container(), flex: 10,),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: loginLightBlue,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(35),
            ),
            child: bodyStream1(size),
          ),
          flex: 80,),
        Expanded(child: Container(), flex: 10,),
      ],),
    );
  }

  Widget footer(){
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(right: 16),
      child:  Text(
        statusText,
        style: const TextStyle(
            fontWeight: FontWeight.normal,fontSize: 13.0,color: Colors.red
        ),
      ),
    );
  }

  Widget bodyStream1(size) {
    return Container(
        child: StreamBuilder<String>(
          initialData: realFurniture,
          stream: controller.stream,
          builder: (context, snapshot1) {
            return StreamBuilder(
              stream:client.updates,
              builder: (context, snapshot2) {
                if (!snapshot1.hasData) {
                  return Container(
                    child: Text("error"),
                  );
                } else {                                                       // 선택값은 있는데 mqtt와 연결이 되지 않았을때
                  final selectedFurniture1 = snapshot1.data;
                  if (!snapshot2.hasData) {
                    if(selectedFurniture1 == "温湿度計"){                  // 온도계선택 & mqtt에서 신호 없음
                      device_temTemperature = '00.0';
                      return Container(
                        child: Column(
                          children: [
                            Expanded(child: bodyDownButton(), flex: 12,),
                            Expanded(child: bodyBattery(0,0,0,0), flex: 5,),
                            Expanded(child: bodyTemperatureGauge(device_temHappy), flex: 39,),
                            Expanded(child:bodyTemperatureText(device_temTemperature,device_temHumidity), flex: 44,),
                          ],
                        ),
                      );
                    }else{
                      device_temTemperature = '00.0';
                      return Container(                                    //    선풍기선택 & mqtt에서 신호 없음
                        child: Column(
                          children: [
                            Expanded(child: bodyDownButton(), flex: 12,),
                            Expanded(child: bodyBattery(0,0,0,0), flex: 5,),
                            Expanded(child: bodyFanState(0,size), flex: 38,),
                            Expanded(child: bodyFanFunction(size), flex: 45,),
                          ],
                        ),
                      );
                    }
                  }else{    // 둘다 연결 되어있을 때
                    if(selectedFurniture1 == "温湿度計"){                  // 온도계선택 & mqtt에서 신호 있음
                      final mqttReceivedMessages = snapshot2.data as List<MqttReceivedMessage<MqttMessage>>;
                      final recMess = mqttReceivedMessages[0].payload as MqttPublishMessage;
                      final newLocationJson = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                      Map<String, dynamic> user = json.decode(newLocationJson);
                      String connectionString  = user['temConnection'];
                      String batteryString = user['temBattery'];
                      String THIhappyString = user['temTHIhappy'];
                      String temperatureString = user['temTemperature'];
                      String humidityString = user['temHumidity'];
                      device_connection  = int.parse(connectionString);
                      device_battery = int.parse(batteryString);
                      device_temHappy = double.parse(THIhappyString);
                      device_temTemperature = temperatureString;
                      device_temHumidity = humidityString;

                      if(device_connection == 0){
                        device_battery = 0;
                        device_temHappy = 0;
                        device_temTemperature = '00.0';
                        device_temHumidity = '00';
                      }
  //                    sendData();

                      return Container(
                        child: Column(
                          children: [
                            Expanded(child: bodyDownButton(), flex: 12,),
                            Expanded(child: bodyBattery(device_connection,device_battery,0,1), flex: 5,),
                            Expanded(child: bodyTemperatureGauge(device_temHappy), flex: 39,),
                            Expanded(child: bodyTemperatureText(device_temTemperature,device_temHumidity), flex: 44,),
                          ],
                        ),
                      );
                    }else{                                                   //    선풍기선택 & mqtt에서 신호 있음
                      final mqttReceivedMessages = snapshot2.data as List<MqttReceivedMessage<MqttMessage>>;
                      final recMess = mqttReceivedMessages[0].payload as MqttPublishMessage;
                      final newLocationJson = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                      Map<String, dynamic> user = json.decode(newLocationJson);
                      String connectionString  = user['fanConnection'];
                      String fanPowerString = user['fanPower'];
                      String batteryString = user['fanBattery'];
                      String fanMotorString = user['fanMotor'];
                      String fanAutoString = user['fanAuto'];
                      String temperatureString = user['temTemperature'];
                      device_autoMode = int.parse(fanAutoString);
                      device_temTemperature = temperatureString;
                      device_connection  = int.parse(connectionString);
                      device_fanPower = int.parse(fanPowerString);
                      device_battery = int.parse(batteryString);
                      device_fanMotor = int.parse(fanMotorString);
                      _fanCounter = device_fanMotor;

                      if(device_connection == 0){
                        device_fanPower = 0;
                        device_battery = 0;
                        device_fanMotor = 0;
                      }

                      return Container(
                        child: Column(
                          children: [
                            Expanded(child: bodyDownButton(), flex: 12,),
                            Expanded(child: bodyBattery(device_connection,device_battery,device_autoMode,device_fanPower), flex: 5,),
                            Expanded(child: bodyFanState(device_fanMotor,size), flex: 38,),
                            Expanded(child: bodyFanFunction(size), flex: 45,),
                          ],
                        ),
                      );
                    }
                  }
                }
              },
            );
          },
        )

    );
  }

  Widget bodyFanState(device_fanMotor,size){
    return Container(
        child: Column(
          children:  [
            Expanded(child: Container(), flex: 23,),
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/images/fan_icon.svg",
                      height: size.height * 0.12,
                      width: size.width * 0.12,
                      color: device_fanMotor >0 ? Colors.blue :Colors.black,
                    ),
                    SvgPicture.asset(
                      "assets/images/fan_icon.svg",
                      height: size.height * 0.12,
                      width: size.width * 0.12,
                      color: device_fanMotor >1 ? Colors.blue :Colors.black,
                    ),
                    SvgPicture.asset(
                      "assets/images/fan_icon.svg",
                      height: size.height * 0.12,
                      width: size.width * 0.12,
                      color: device_fanMotor >2 ? Colors.blue :Colors.black,
                    ),
                  ],
                ),
              ),flex: 77,
            )
          ],
        )
    );
  }

  Widget bodyFanFunction(size){
    return Container(
      child:Column(
        children: [
          SizedBox(height: size.height * 0.06),
          Row(
            children: [
              SizedBox(width: size.width * 0.1),
              SizedBox(
                width: size.width * 0.3,
                height: size.height * 0.11,
                child: Ink(
                  decoration: ShapeDecoration(
                    color: Colors.red,
                    shape: CircleBorder(),
                  ),
                  child: TapDebouncer(
                      cooldown: const Duration(milliseconds: 500),
                      onTap: () async {
                        _fanCounter = 0;
                        _fanCounterString = _fanCounter.toString();
                        publishFanString(_fanCounterString);
                      },
                      builder: (_, TapDebouncerFunc? onTap) {
                        return IconButton(
                          icon: const Icon(Icons.stop),
                          color: Colors.white,
                          onPressed: onTap
                        );
                      },
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.07),
              SizedBox(
                width: size.width * 0.2,
                child: Column(
                  children: [
                    TapDebouncer(
                      cooldown: const Duration(milliseconds: 500),
                      onTap: () async {
                        if(_fanCounter <3){
                          _fanCounter++;
                          _fanCounterString = _fanCounter.toString();
                        }
                        publishFanString(_fanCounterString);
                      },
                      builder: (_, TapDebouncerFunc? onTap) {
                        return ElevatedButton(
                            child: const Icon(Icons.arrow_drop_up),
                          onPressed: onTap,
                        );
                      },
                    ),
                    TapDebouncer(
                      cooldown: const Duration(milliseconds: 500),
                      onTap: () async {
                        if(_fanCounter >0){
                          _fanCounter--;
                          _fanCounterString = _fanCounter.toString();
                        }
                        publishFanString(_fanCounterString);
                      },
                      builder: (_, TapDebouncerFunc? onTap) {
                        return ElevatedButton(
                            child: const Icon(Icons.arrow_drop_down),
                          onPressed: onTap,
                        );
                      },
                    ),
                  ],
                ) ,
              ),

            ],
          ),
          SizedBox(height: size.height * 0.04),
        ],
      ),

    );
  }

  Widget bodyTemperatureGauge(device_happy){
    return Container(
        child: Column(
          children: [
            Expanded(child: Container(), flex: 45,),
            Expanded(child: Container(
                child:  SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                        useRangeColorForAxis: true,
                        showLabels: false,
                        showTicks: false,
                        startAngle: 180,
                        endAngle: 360,
                        minimum: 0,
                        maximum: 100,
                        radiusFactor: 2.3,
                        axisLineStyle: const AxisLineStyle(
                            color: Color(0xe1d7d2d2e1),
                            thickness: 0.2,
                            thicknessUnit: GaugeSizeUnit.factor),

                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                              angle: 100,
                              widget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  checkGaugeValue(device_happy),
                                ],
                              )),
                        ],

                        pointers: <GaugePointer>[
                          RangePointer(
                              value: device_happy,
                              cornerStyle: CornerStyle.bothCurve,
                              enableAnimation: true,
                              animationDuration: 1000,
                              animationType: AnimationType.ease,
                              sizeUnit: GaugeSizeUnit.factor,
                              gradient: SweepGradient(
                                  colors: <Color>[Color(0xFF9DDDFF), Color(0xFF9DDDFF)],
                                  stops: <double>[0.25, 0.75]),
                              color: Color(0xFF69BACE),
                              width: 0.2),
                        ]),
                  ],
                )
            ), flex: 45,),
            Expanded(child: Container(), flex: 10,),
          ],
        )

    );
  }

  Widget checkGaugeValue(device_happy){
    if(device_happy == 0){     // 매우추움
      return Container(
        child :  Image.asset('assets/images/stopnormal.PNG',
          height:56,
          width: 56,),
      );
    }
    if(device_happy <= 55 && device_happy > 0){     // 매우추움
      return Container(
        child :  Image.asset('assets/images/socold.PNG',
          height:56,
          width: 56,),
      );
    }
    if(device_happy <= 60 && device_happy > 55){      // 추움
      return Container(
        child :  Image.asset('assets/images/cold.PNG',
          height:56,
          width: 56,),
      );
    }
    if(device_happy <= 65 && device_happy > 60){   // 보통
      return Container(
        child :  Image.asset('assets/images/normal.PNG',
          height:56,
          width: 56,),
      );
    }
    if(device_happy <= 70 && device_happy > 65){   // 좋음
      return Container(
        child :  Image.asset('assets/images/good.PNG',
          height:56,
          width: 56,),
      );
    }
    if(device_happy <= 75 && device_happy > 70){   // 보통
      return Container(
        child :  Image.asset('assets/images/normal.PNG',
          height:56,
          width: 56,),
      );
    }
    if(device_happy <= 80 && device_happy > 75){  // 더움
      return Container(
        child :  Image.asset('assets/images/hot.PNG',
          height:56,
          width: 56,),
      );
    }
    else{                                           // 매우더움
      return Container(
        child :  Image.asset('assets/images/sohot2.PNG',
          height:56,
          width: 56,),
      );
    }
  }


  Widget bodyTemperatureText(device_temperature,device_humidity){
    return Container(
        child: Column(
          children: [
            Expanded(child: Row(
              children: [
                Expanded(child: Container(), flex: 15,),
                Expanded(child: Container(
                    child :Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Container(child:
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
                              Text('温度'),
                              Icon(
                                Icons.thermostat,
                                color: Colors.black,
                                size: 40.0,
                              ),
                            ]
                        ),), flex: 20,),
                        Expanded(child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Text(device_temperature,
                                  style:
                                  TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.normal
                                  ),
                                ),
                                Text(' °C',
                                  style:TextStyle(
                                      height: 3.5,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal
                                  ),
                                ),
                              ],
                            )
                        ), flex: 80,),
                      ],
                    )
                ), flex: 86,),
                Expanded(child: Container(), flex: 8,),
              ],
            ), flex: 38,),

            Expanded(child: Container(), flex: 10,),
            Expanded(child: Row(
              children: [
                Expanded(child: Container(), flex: 15,),
                Expanded(child: Container(
                    child :Row(
                      children: [
                        Expanded(child: Container(child:
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
                              Text('湿度'),
                              Icon(
                                Icons.water,
                                color: Colors.black,
                                size: 40.0,
                              ),
                            ]
                        ),), flex: 20,),
                        Expanded(child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Text("   $device_humidity",
                                  style:
                                  TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.normal
                                  ),
                                ),
                                Text(' %',
                                  style:TextStyle(
                                      height: 3.5,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal
                                  ),
                                ),
                              ],
                            )
                        ), flex: 80,),
                      ],
                    )
                ), flex: 86,),
                Expanded(child: Container(), flex: 8,),
              ],
            ), flex: 60,),
            Expanded(child: Container(), flex: 15,),
          ],
        )
    );
  }


  Widget bodyDownButton() {
    return Container(
      child: DropdownButton<String>(
        key: dropdownState,
        onChanged: (value) async{
          setState(() {
            publishString("1");
            _selectedFurniture = value;
            realFurniture = _selectedFurniture!;
            controller.sink.add(realFurniture);
          });
        },
        value: _selectedFurniture,
        // Hide the default underline    //
        underline: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: loginLightBlue,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        hint:
        Row(
          children: [
            Expanded(child: Container(), flex: 41,),
            Expanded(child:
            Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0) ,
                  child: Text(
                    '温湿度計',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black),
                  ),
                )), flex: 30,),
            Expanded(child: Container(), flex: 29,),
          ],
        ),
        isExpanded: true,

        // The list of options
        items: _furniture
            .map((e) =>
            DropdownMenuItem(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  e,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              value: e,
            ))
            .toList(),
        // Customize the selected item
        selectedItemBuilder: (BuildContext context) =>
            _furniture
                .map((e) =>
                Row(
                  children: [
                    Expanded(child: Container(), flex: 41,),
                    Expanded(child:
                    Container(
                      child: Center(
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ), flex: 30,),
                    Expanded(child: Container(), flex: 29,),
                  ],
                )
            )
                .toList(),
      ),
    );
  }

  Widget bodyBattery(device_connection,device_battery,device_autoMode,device_fanPower){
    if(device_connection == 1 ){
      if(device_fanPower == 1){
        if(device_autoMode == 1){
          return Row(
            children: [
              Expanded(child: Container(), flex: 54),
              Expanded(child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  child:  Container(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: (){
                        _disconncet();
                        AlanVoice.removeButton();
                        BlocProvider.of<HomeNavigatorCubit>(context).showAuto();
                      }, icon: Icon(Icons.psychology),
                      color: Color(0xFF616161),),
                  )
              ), flex: 9),
              Expanded(child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  child:  Container(
                    child: const Icon(Icons.power,
                      color: Color(0xFF616161),
                    ),
                  )
              ), flex: 9),
              Expanded(child: Container(
                padding: const EdgeInsets.only(right: 8),
                child: const Icon(Icons.wifi,
                  color: Color(0xFF616161),
                ),), flex: 10,),

              Expanded(child:
              Container(
                padding: const EdgeInsets.only(right: 12),
                child: BatteryIndicator(
                  batteryFromPhone: false,
                  batteryLevel: device_battery,
                  style: BatteryIndicatorStyle.values[0],
                  colorful: true,
                  showPercentNum: true,
                  mainColor: Colors.black26,
                  size: 13.0,
                  ratio: 2.0,
                  showPercentSlide: true,
                ),
              ), flex: 18,),
            ],
          );
        }else{               // if automode off
          return Row(
            children: [
              Expanded(child: Container(), flex: 54),
              Expanded(child: Container(), flex: 9),
              Expanded(child: Container(
                child: const Icon(Icons.power,
                  color: Color(0xFF616161),
                ),
              ), flex: 9),
              Expanded(child: Container(
                padding: const EdgeInsets.only(right: 8),
                child: const Icon(Icons.wifi,
                  color: Color(0xFF616161),
                ),), flex: 10,),

              Expanded(child:
              Container(
                padding: const EdgeInsets.only(right: 12),
                child: BatteryIndicator(
                  batteryFromPhone: false,
                  batteryLevel: device_battery,
                  style: BatteryIndicatorStyle.values[0],
                  colorful: true,
                  showPercentNum: true,
                  mainColor: Colors.black26,
                  size: 13.0,
                  ratio: 2.0,
                  showPercentSlide: true,
                ),
              ), flex: 18,),
            ],
          );
        }
      }else{
        if(device_autoMode == 1){
          return Row(
            children: [
              Expanded(child: Container(), flex: 54),
              Expanded(child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  child:  Container(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: (){
                        _disconncet();
                        AlanVoice.removeButton();
                        BlocProvider.of<HomeNavigatorCubit>(context).showAuto();
                      }, icon: Icon(Icons.psychology),
                      color: Color(0xFF616161),),
                  )
              ), flex: 9),
              Expanded(child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  child:  Container(
                    child: const Icon(Icons.power_off,
                      color: Color(0xFF616161),
                    ),
                  )
              ), flex: 9),
              Expanded(child: Container(
                padding: const EdgeInsets.only(right: 8),
                child: const Icon(Icons.wifi,
                  color: Color(0xFF616161),
                ),), flex: 10,),

              Expanded(child:
              Container(
                padding: const EdgeInsets.only(right: 12),
                child: BatteryIndicator(
                  batteryFromPhone: false,
                  batteryLevel: device_battery,
                  style: BatteryIndicatorStyle.values[0],
                  colorful: true,
                  showPercentNum: true,
                  mainColor: Colors.black26,
                  size: 13.0,
                  ratio: 2.0,
                  showPercentSlide: true,
                ),
              ), flex: 18,),
            ],
          );
        }else{               // if automode off
          return Row(
            children: [
              Expanded(child: Container(), flex: 54),
              Expanded(child: Container(), flex: 9),
              Expanded(child: Container(
                child: const Icon(Icons.power_off,
                  color: Color(0xFF616161),
                ),
              ), flex: 9),
              Expanded(child: Container(
                padding: const EdgeInsets.only(right: 8),
                child: const Icon(Icons.wifi,
                  color: Color(0xFF616161),
                ),), flex: 10,),

              Expanded(child:
              Container(
                padding: const EdgeInsets.only(right: 12),
                child: BatteryIndicator(
                  batteryFromPhone: false,
                  batteryLevel: device_battery,
                  style: BatteryIndicatorStyle.values[0],
                  colorful: true,
                  showPercentNum: true,
                  mainColor: Colors.black26,
                  size: 13.0,
                  ratio: 2.0,
                  showPercentSlide: true,
                ),
              ), flex: 18,),
            ],
          );
        }
      }


    }else{
      return Row(
        children: [
          Expanded(child: Container(), flex: 63),
          Expanded(child: Container(
            padding: const EdgeInsets.only(right: 8),
            child: const Icon(Icons.power_off,
              color: Color(0xFF616161),
            ),
          ), flex: 9),
          Expanded(child: Container(
            padding: const EdgeInsets.only(right: 8),
            child: const Icon(Icons.wifi_off,
              color: Color(0xFF616161),
            ),), flex: 10,),
          Expanded(child:
          Container(
            padding: const EdgeInsets.only(right: 12),
            child: BatteryIndicator(
              batteryFromPhone: false,
              batteryLevel: 0,
              style: BatteryIndicatorStyle.values[0],
              colorful: true,
              showPercentNum: true,
              mainColor: Colors.black26,
              size: 13.0,
              ratio: 2.0,
              showPercentSlide: true,
            ),
          ), flex: 18,),
        ],
      );
    }
  }













  _connect() async{
    isConnected =await mqttConnect(idTextController.trim());
    publishString("1");
  }

  _disconncet() {
    client.disconnect();
  }

  Future<bool> mqttConnect(String uniqueId) async {
    setStatus("接続中");
    ByteData rootCA = await rootBundle.load('assets/certs/RootCA.pem');
    ByteData deviceCert =
    await rootBundle.load('assets/certs/DeviceCertificate.crt');
    ByteData privateKey = await rootBundle.load('assets/certs/Private.key');

    SecurityContext context = SecurityContext.defaultContext;
    context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
    context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
    context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

    client.securityContext = context;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.port = 8883;
    client.secure = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.pongCallback = pong;

    final MqttConnectMessage connMess =
    MqttConnectMessage().withClientIdentifier(uniqueId).startClean();
    client.connectionMessage = connMess;

    await client.connect();
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print("Connected to AWS Successfully!");
    } else {
      return false;
    }


    client.subscribe(topicSubscribe, MqttQos.atMostOnce);

    return true;
  }




  void setStatus(String content) {
    setState(() {
      statusText = content;
    });
  }

  void onConnected() {
    setStatus("サーバーに接続されました。");
  }

  void onDisconnected() {
    setStatus("接続が切れました");
    isConnected = false;
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  void publishString(String data)
  {
    if(client.connectionStatus!.state==MqttConnectionState.connected)
    {
      String jData = jsonEncode(
        <String, dynamic>{"start": data},
      );
      final MqttClientPayloadBuilder builder=MqttClientPayloadBuilder();
      builder.addString(jData);
      client.publishMessage(topicPublish, MqttQos.atMostOnce, builder.payload!);
    }
  }

  void publishFanString(String data)
  {
    if(client.connectionStatus!.state==MqttConnectionState.connected)
    {
      String jData = jsonEncode(
        <String, dynamic>{"fanMotor": data},
      );
      final MqttClientPayloadBuilder builder=MqttClientPayloadBuilder();
      builder.addString(jData);
      client.publishMessage(topicFanPublish, MqttQos.atMostOnce, builder.payload!);
    }
  }


}

