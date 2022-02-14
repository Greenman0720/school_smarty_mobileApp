import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:battery_indicator/battery_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:test_new_version/constants.dart';
import 'package:test_new_version/home/home_drawer.dart';

import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/session_cubit.dart';
import 'package:test_new_version/home/home_bloc.dart';

class MonitorView extends StatefulWidget {
  @override
  State<MonitorView> createState() => _MonitorViewViewState();
}

class _MonitorViewViewState extends State<MonitorView> {

  int device_temConnection = 0;
  int device_temState = 0;
  int device_temBattery = 0;

  int device_fanConnection = 0;
  int device_fanPower = 0;
  int device_fanBattery = 0;
  int device_fanMotor = 0;

  String statusText = "";
  bool isConnected = false;
  String idTextController = "seon";

  final MqttServerClient client =
  MqttServerClient('a28gkg1ipmelf1-ats.iot.ap-northeast-2.amazonaws.com', '');
  String topicSubscribe = 'school_project/flutter/test_new_version/monitorpage/subscribe';
  String topicPublish = 'school_project/flutter/test_new_version/monitorpage/publish';
  String topicFanPublish = 'school_project/flutter/test_new_version/monitorpage/publish/fanmotor';


  @override
  void initState() {
    _connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final sessionCubit = context.read<SessionCubit>();

    return BlocProvider(
      create: (context) => HomeBloc(
        user: sessionCubit.selectedUser ?? sessionCubit.currentUser as User,
        isCurrentUser: sessionCubit.isCurrentUserSelected,
      ),

      child: Scaffold(
        appBar: AppBar(
          title: const Text("モニタリング",
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
            Expanded(child: Container(),flex: 10,),
            Expanded(child: Container(child:body(size),), flex: 77,),
            Expanded(child: Container(),flex: 8,),
            Expanded(child: Container(child: footer(),), flex: 5,),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: bodyStream1(size)
            )
          ],
        ),
    );
  }


  Widget bodyStream1(size){
    return StreamBuilder(
      stream: client.updates,
      builder: (context,snapshot){
        if(!snapshot.hasData) {
          return DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Expanded(child: Text('名前',textAlign: TextAlign.center,))),
              DataColumn(
                label: Expanded(child: Text("WiFi", textAlign:TextAlign.center)),
              ),
              DataColumn(
                label: Expanded(child: Text("電源", textAlign:TextAlign.center)),
              ),
              DataColumn(
                label: Expanded(child: Text("バッテリー", textAlign:TextAlign.center)),
              ),
              DataColumn(
                label: Expanded(child: Text("ボタン", textAlign:TextAlign.center)),
              ),
            ],
            rows: <DataRow>[
              DataRow(
                cells: <DataCell>[
                  DataCell(Center(child: Text('温湿度計',textAlign: TextAlign.center,))),
                  DataCell(Center(child: deviceWifi(0))),
                  DataCell(Center(child: deviceState(3))),
                  DataCell(Center(child:deviceBattery(111))),
                  DataCell(Center(child:deviceButton(3))),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Center(child: Text('扇風機'))),
                  DataCell(Center(child: deviceWifi(0))),
                  DataCell(Center(child: deviceState(3))),
                  DataCell(Center(child:deviceBattery(111))),
                  DataCell(Center(child:deviceButton(3))),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Center(child: Text('冷蔵庫'))),
                  DataCell(Center(child: deviceWifi(0))),
                  DataCell(Center(child: deviceState(3))),
                  DataCell(Center(child:deviceBattery(111))),
                  DataCell(Center(child:deviceButton(3))),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Center(child: Text('テレビ'))),
                  DataCell(Center(child: deviceWifi(0))),
                  DataCell(Center(child: deviceState(3))),
                  DataCell(Center(child:deviceBattery(111))),
                  DataCell(Center(child:deviceButton(3))),
                ],
              ),
            ],
          );
        }else{
          final mqttReceivedMessages = snapshot.data as List<MqttReceivedMessage<MqttMessage>>;
          final recMess = mqttReceivedMessages[0].payload as MqttPublishMessage;
          final newLocationJson = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          Map<String, dynamic> user = json.decode(newLocationJson);
          String temConnectionString  = user['temConnection'];
          String temStateString = user['temState'];
          String temBatteryString = user['temBattery'];

          String fanConnectionString  = user['fanConnection'];
          String fanPowerString = user['fanPower'];
          String fanBatteryString = user['fanBattery'];
          String fanMotorString = user['fanMotor'];

          device_temConnection  = int.parse(temConnectionString);
          device_temState = int.parse(temStateString);
          device_temBattery = int.parse(temBatteryString);

          if(device_temConnection == 0){
            device_temState = 3;
            device_temBattery = 111;
          }

          device_fanConnection  = int.parse(fanConnectionString);
          device_fanPower = int.parse(fanPowerString);
          device_fanBattery = int.parse(fanBatteryString);
          device_fanMotor = int.parse(fanMotorString);

          if(device_fanConnection == 0){
            device_fanPower = 3;
            device_fanBattery = 111;
            device_fanMotor = 3;
          }

          return DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Expanded(child: Text("名前", textAlign:TextAlign.center)),
              ),
              DataColumn(
                label: Expanded(child: Text("WiFi", textAlign:TextAlign.center)),
              ),
              DataColumn(
                label: Expanded(child: Text("電源", textAlign:TextAlign.center)),
              ),
              DataColumn(
                label: Expanded(child: Text("バッテリー", textAlign:TextAlign.center)),
              ),
              DataColumn(
                label: Expanded(child: Text("ボタン", textAlign:TextAlign.center)),
              ),
            ],
            rows: <DataRow>[
              DataRow(
                cells: <DataCell>[
                  DataCell(Center(child: Text('温湿度計'))),
                  DataCell(Center(child: deviceWifi(device_temConnection))),
                  DataCell(Center(child: deviceState(device_temState))),
                  DataCell(Center(child:deviceBattery(device_temBattery))),
                  DataCell(Center(child:deviceButton(3))),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Center(child: Text('扇風機'))),
                  DataCell(Center(child: deviceWifi(device_fanConnection))),
                  DataCell(Center(child: deviceState(device_fanPower))),
                  DataCell(Center(child:deviceBattery(device_fanBattery))),
                  DataCell(Center(child:deviceButton(device_fanMotor))),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Center(child: Text('冷蔵庫'))),
                  DataCell(Center(child: deviceWifi(0))),
                  DataCell(Center(child: deviceState(3))),
                  DataCell(Center(child:deviceBattery(111))),
                  DataCell(Center(child:deviceButton(3))),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Center(child: Text('テレビ'))),
                  DataCell(Center(child: deviceWifi(0))),
                  DataCell(Center(child: deviceState(3))),
                  DataCell(Center(child:deviceBattery(111))),
                  DataCell(Center(child:deviceButton(3))),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget deviceWifi(int wifiValue){
    if(wifiValue == 1){
      return Container(
        child:  const Icon(Icons.wifi,
          color: Color(0xFF616161),
        )

      );
    }else{
      return Container(
          child:  const Icon(Icons.wifi_off,
            color: Color(0xFF616161),
          )

      );
    }
  }

  Widget deviceState(int stateValue){
    if(stateValue == 1){
      return Container(
          //alignment: Alignment.centerRight,
          child:  const Icon(Icons.power ,
            color: Color(0xFF616161),
          )

      );
    }if(stateValue == 0){
      return Container(
          child:  const Icon(Icons.power_off,
            color: Color(0xFF616161),
          )

      );
    }else{
      return Container(
          child:  const Text("",
          )
      );
    }
  }

  Widget deviceBattery(int batteryValue){
    if(batteryValue == 111){
      return Container(
          child:  const Text("",
          ));
    }else{
      return Container(
          child:  BatteryIndicator(
            batteryFromPhone: false,
            batteryLevel: batteryValue,
            style: BatteryIndicatorStyle.values[0],
            colorful: true,
            showPercentNum: true,
            mainColor: Colors.black26,
            size: 14.0,
            ratio: 3.5,
            showPercentSlide: true,
          ),
      );
    }
  }

  Widget deviceButton(int stateValue){
    if(stateValue == 1){
      return Container(
        //alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              publishFanString('0');
            },
            child: const Text('OFF'),
          ),
      );
    }if(stateValue == 0){
      return Container(
        //alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
             publishFanString('1');
          },
            child: const Text('ON'),
        ),
      );
    }else{
      return Container(
          child:  const Text("",
          )
      );
    }
  }

  Widget footer(){
    return  Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child:  Text(
          statusText,
          style: const TextStyle(
              fontWeight: FontWeight.normal,fontSize: 13.0,color: Colors.red
          ),
        ),
    );
  }





  _connect() async{

    isConnected =await mqttConnect(idTextController.trim());
    publishString("start");

    // progressDialog.dismiss();

  }

  Future<bool> mqttConnect(String uniqueId) async {
    setStatus("接続中");

    // After adding your certificates to the pubspec.yaml, you can use Security Context.

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

  void publishString(String data)
  {
    /*
         Checks if MQTT is connected and TextInput contains non empty String
    */
    if(client.connectionStatus!.state==MqttConnectionState.connected)
    {
      String jData = jsonEncode(
        <String, dynamic>{"start": data},
      );

      final MqttClientPayloadBuilder builder=MqttClientPayloadBuilder();
      builder.addString(jData);
      client.publishMessage(topicPublish, MqttQos.atMostOnce, builder.payload!);
      //client.published.listen((MqttPublishMessage message) {
      //  print(" string publilshed on topic->"+message.variableHeader.topicName.toString()+" with Qos->"+message.header.qos.toString());
      // });
    }
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