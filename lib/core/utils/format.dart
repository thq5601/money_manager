import 'package:intl/intl.dart';

String formatVND(num amount) {
  final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  return format.format(amount);
}
