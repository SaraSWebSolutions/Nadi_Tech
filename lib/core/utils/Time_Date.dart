import 'package:intl/intl.dart';

String formatDateForUI(DateTime dateTime) {
  try {
    return DateFormat("dd/MM/yyyy hh:mm a")
        .format(dateTime.toLocal());
  } catch (e) {
    return "-";
  }
}
