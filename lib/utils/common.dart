String parseDateTime(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  String suffix;
  if (dateTime.day == 1 || dateTime.day == 21 || dateTime.day == 31) {
    suffix = "st";
  } else if (dateTime.day == 2 || dateTime.day == 22) {
    suffix = "nd";
  } else if (dateTime.day == 3 || dateTime.day == 23) {
    suffix = "rd";
  } else {
    suffix = "th";
  }
  return "${weekDays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}$suffix, ${dateTime.year}";
}

String parseDateTimeShort(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  return "${dateTime.day}.${dateTime.month}.${dateTime.year}";
}
