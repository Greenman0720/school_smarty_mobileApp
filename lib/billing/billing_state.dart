import 'package:test_new_version/models/User.dart';
import 'package:test_new_version/billing/billing_view.dart';

class BillingState {
  final User user;
  final bool isCurrentUser;

  String? get username => user.username;
  String? get email => user.email;
  String? get startYearDate => BillingViewState.startYearDate;
  String? get startMonthDate => BillingViewState.startMonthDate;
  String? get startDayDate => BillingViewState.startDayDate;
  String? get endYearDate => BillingViewState.endYearDate;
  String? get endMonthDate => BillingViewState.endMonthDate;
  String? get endDayDate => BillingViewState.endDayDate;
  String? get realPeriod => BillingViewState.realPeriod;
  String? get startFullDate => BillingViewState.startFullDate;
  String? get endFullDate => BillingViewState.endFullDate;

  BillingState({
    required User user,
    required bool isCurrentUser,
  })  : this.user = user,
        this.isCurrentUser = isCurrentUser;


  BillingState copyWith({
    String? startYearDate,
    String? startMonthDate,
    String? startDayDate,
    String? endYearDate,
    String? endMonthDate,
    String? endDayDate,
    String? realPeriod,
    String? startFullDate,
    String? endFullDate,

    User? user,
  }) {
    return BillingState(
      user: user ?? this.user,
      isCurrentUser:  this.isCurrentUser,
    );
  }
}
