abstract class BillingEvent {}


class DatePickerSubmitted extends BillingEvent {
  final String? startYearDate;
  final String? startMonthDate;
  final String? startDayDate;
  final String? endYearDate;
  final String? endMonthDate;
  final String? endDayDate;
  final String? startFullDate;
  final String? endFullDate;



  DatePickerSubmitted({
    this.startYearDate,
    this.startMonthDate,
    this.startDayDate,
    this.endYearDate,
    this.endMonthDate,
    this.endDayDate,
    this.startFullDate,
    this.endFullDate
  });



}