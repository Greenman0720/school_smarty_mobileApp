import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/billing/billing_event.dart';
import 'package:test_new_version/billing/billing_state.dart';


class BillingBloc extends Bloc<BillingEvent, BillingState> {
  BillingBloc({required User user, required bool isCurrentUser})
      : super(BillingState(user: user, isCurrentUser: isCurrentUser));

  @override
  Stream<BillingState> mapEventToState(BillingEvent event) async* {
 if (event is DatePickerSubmitted) {
      yield state.copyWith(
          startYearDate: event.startYearDate,
          startMonthDate: event.startMonthDate,
          startDayDate: event.startDayDate,
          endYearDate: event.endYearDate,
          endMonthDate: event.endMonthDate,
          endDayDate: event.endDayDate,
          startFullDate: event.startFullDate,
          endFullDate: event.endFullDate,
      );
    }
  }
}

/*
    startYearDate
    startMonthDate
    startDayDate
    endYearDate
    endMonthDate
    endDayDate

 */