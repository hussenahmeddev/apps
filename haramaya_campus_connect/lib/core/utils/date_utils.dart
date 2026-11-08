import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _fullDateFormat = DateFormat('MMMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('MMM d');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy • h:mm a');
  static final DateFormat _dayFormat = DateFormat('EEEE');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  /// Formats a DateTime to "November 4, 2026"
  static String fullDate(DateTime date) => _fullDateFormat.format(date);

  /// Formats a DateTime to "Nov 4, 2026"
  static String shortDate(DateTime date) => _shortDateFormat.format(date);

  /// Formats a DateTime to "Nov 4"
  static String dayMonth(DateTime date) => _dayMonthFormat.format(date);

  /// Formats a DateTime to "3:30 PM"
  static String time(DateTime date) => _timeFormat.format(date);

  /// Formats to "Nov 4, 2026 • 3:30 PM"
  static String dateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Formats to "Monday"
  static String dayName(DateTime date) => _dayFormat.format(date);

  /// Formats to "November 2026"
  static String monthYear(DateTime date) => _monthYearFormat.format(date);

  /// Returns relative time like "2 hours ago"
  static String relative(DateTime date) => timeago.format(date);

  /// Returns true if the date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns true if the date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Returns a human-friendly date label
  static String friendlyDate(DateTime date) {
    if (isToday(date)) return 'Today, ${time(date)}';
    if (isTomorrow(date)) return 'Tomorrow, ${time(date)}';
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.inDays > 0 && diff.inDays < 7) {
      return '${dayName(date)}, ${time(date)}';
    }
    return dateTime(date);
  }

  /// Returns date range string
  static String dateRange(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${shortDate(start)} • ${time(start)} - ${time(end)}';
    }
    return '${shortDate(start)} - ${shortDate(end)}';
  }

  /// Returns whether event is upcoming
  static bool isUpcoming(DateTime date) => date.isAfter(DateTime.now());

  /// Returns whether event is ongoing (between start and end)
  static bool isOngoing(DateTime start, DateTime end) {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }
}

