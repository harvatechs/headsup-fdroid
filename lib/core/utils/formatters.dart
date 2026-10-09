class Formatters {
  /// Format coordinates into human-readable string: e.g. "37.7749° N, 122.4194° W"
  static String formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
  }

  /// Format timestamp into relative string: "Just now", "2m ago", "1h ago", etc.
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins min${mins > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hr${hours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  /// Format timestamp to exact time: "10:35 AM"
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$formattedHour:$minute $period';
  }

  /// Format timestamp to date: "Oct 24, 2026"
  static String formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dateTime.month - 1];
    return '$month ${dateTime.day}, ${dateTime.year}';
  }

  /// Format full date and time: "Oct 24, 2026 • 10:35 AM"
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} • ${formatTime(dateTime)}';
  }

  /// Format tilt angle in degrees: "14.2°"
  static String formatAngle(double degrees) {
    return '${degrees.toStringAsFixed(1)}°';
  }
}
