import 'package:flutter_bloc/flutter_bloc.dart';

enum BillingNavigatorState { billing,billingResult,}

class BillingNavigatorCubit extends Cubit<BillingNavigatorState> {
  BillingNavigatorCubit() : super(BillingNavigatorState.billing);

  void showBilling() => emit(BillingNavigatorState.billing);
  void showBillingResult() {

    emit(BillingNavigatorState.billingResult);
  }

}





