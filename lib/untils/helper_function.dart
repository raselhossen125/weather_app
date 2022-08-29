import 'package:intl/intl.dart';

String getFormattedDateTime(num dt, String pattern) {
  return DateFormat(pattern).format(
      DateTime.fromMillisecondsSinceEpoch(
          dt.toInt() * 1000));
}
