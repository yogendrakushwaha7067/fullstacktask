import 'package:intl/intl.dart';

String formatDateWithMonthNameAndTime(DateTime dateTime) {
  // Create a DateFormat instance with the desired pattern
  final DateFormat formatter = DateFormat('MMMM dd, yyyy h:mm a');

  // Format the provided DateTime object
  return formatter.format(dateTime);
}