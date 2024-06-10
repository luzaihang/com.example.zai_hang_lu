import 'package:intl/intl.dart';

String formatDateTimeToMinutes(DateTime dateTime) {
  // 获取当前年份
  int currentYear = DateTime.now().year;

  // 获取日期年份
  int dateYear = dateTime.year;

  // 当年份是今年时，仅显示月、日和时间
  if (dateYear == currentYear) {
    final DateFormat formatter = DateFormat('MM-dd HH:mm');
    return formatter.format(dateTime);
  } else {
    // 否则，显示完整年份、月、日和时间
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }
}