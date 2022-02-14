import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/session_cubit.dart';

import 'package:test_new_version/billing/billing_state.dart';
import 'package:test_new_version/billing/billing_bloc.dart';
import 'package:test_new_version/billing/billing_navigator_cubit.dart';

import 'billing_drawer.dart';
import 'billing_event.dart';

class BillingView extends StatefulWidget {
  @override
  State<BillingView> createState() => BillingViewState();
}

class BillingViewState extends State<BillingView> {
  String? _selectedPeriod;

  final DateRangePickerController _controller = DateRangePickerController();
  final List<String> views = <String>['日', '月', '年'];

  static String realPeriod = "日";
  static String startYearDate = '';
  static String startMonthDate = '';
  static String startDayDate = '';
  static String endYearDate = '';
  static String endMonthDate = '';
  static String endDayDate = '';
  static String startFullDate = '';
  static String endFullDate = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sessionCubit = context.read<SessionCubit>();
    return BlocProvider(
      create: (context) =>
          BillingBloc(
            user: sessionCubit.selectedUser ?? sessionCubit.currentUser as User,
            isCurrentUser: sessionCubit.isCurrentUserSelected,
          ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("期間設定",
            style: const TextStyle(
              fontSize: 20.0,
            ),),
          //automaticallyImplyLeading: true,
          centerTitle: true,
          elevation: 0.0,
        ),
        drawer: Drawer2(),
        body: Container(
          child: Column(
            children: [
              //Expanded(child: Text(startYearDate+'/'+startMonthDate+'/'+startDayDate+' ~ '+endYearDate+'/'+endMonthDate+'/'+endDayDate), flex: 8,),
              Expanded(child: Container(), flex: 8,),
              Expanded(child: dropDownButton(), flex: 5,),
              Expanded(child: calendar(context), flex: 85,),
              Expanded(child: Container(), flex: 2,),
            ],
          ),
        )
      ),
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
         startYearDate = DateFormat('yyyy').format(args.value.startDate).toString();
         startMonthDate = DateFormat('MM').format(args.value.startDate).toString();
         startDayDate = DateFormat('dd').format(args.value.startDate).toString();
         endYearDate = DateFormat('yyyy').format(args.value.endDate ?? args.value.endDate).toString();
         endMonthDate = DateFormat('MM').format(args.value.endDate ?? args.value.endDate).toString();
         endDayDate = DateFormat('dd').format(args.value.endDate ?? args.value.endDate).toString();
         startFullDate = startYearDate + startMonthDate + startDayDate;
         endFullDate = endYearDate + endMonthDate + endDayDate;
      }
    });
  }

  Widget dropDownButton(){
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(
        right: 20.0,
      ),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        onChanged: (value) async{
          setState(() {
            _selectedPeriod = value;
            realPeriod = _selectedPeriod!;
            if (value == '日') {
              _controller.view = DateRangePickerView.month;
            } else if (value == '月') {
              _controller.view = DateRangePickerView.year;
            } else if (value == '年') {
              _controller.view = DateRangePickerView.decade;
            }
          });
        },
        hint:  Text(realPeriod,
          style: TextStyle(
              fontSize: 15,
              color: Colors.black),
        ),
        underline: Container(),
        items: views
            .map((e) =>
            DropdownMenuItem(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  e,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              value: e,
            ))
            .toList(),
        selectedItemBuilder: (BuildContext context) =>
            views.map((e) =>
                Text(e,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
            )
                .toList(),
      ),
    );
  }

  Widget calendar(BuildContext context){
    return BlocBuilder<BillingBloc, BillingState>(builder: (context, state) {
    return Container(
      // margin: const EdgeInsets.fromLTRB(50, 150, 50, 150),
      child: SfDateRangePicker(
        allowViewNavigation: false,
        onSelectionChanged: _onSelectionChanged,
        showActionButtons: true,
        selectionMode: DateRangePickerSelectionMode.range,
        controller: _controller,
        view: DateRangePickerView.month,
        cancelText: 'キャンセル',
        confirmText: '確認',
        onSubmit: (Object val){
         if(realPeriod== '月'){
           endDayDate = '31';
         }
         if(realPeriod== '年'){
           endMonthDate = '12';
           endDayDate = '31';
         }
         context.read<BillingBloc>().add(DatePickerSubmitted(
           startYearDate: startYearDate,
           startMonthDate: startMonthDate,
           startDayDate: startDayDate,
           endYearDate: endYearDate,
           endMonthDate: endMonthDate,
           endDayDate: endDayDate,
           startFullDate: startFullDate,
           endFullDate: endFullDate
         ));
         BlocProvider.of<BillingNavigatorCubit>(context).showBillingResult();
        },
        onCancel: (){
          setState(() {
            _controller.selectedRanges = null;
            startYearDate = '';
            startMonthDate = '';
            startDayDate = '';
            endYearDate = '';
            endMonthDate = '';
            endDayDate = '';
          },
          );
          },
      ),
    );
    });
  }
}

