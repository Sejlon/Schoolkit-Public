class WorldTime {
  String time = "00:00";
  String dayOfWeek = "Monday";
  bool dayTime = true;

  static const daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  bool isDaytime(DateTime dateTime) {
    int hour = dateTime.hour; // Hour of the day (0-23)
    return hour >= 6 && hour < 18; // Assuming 6 AM to 6 PM is daytime
  }

  Future<void> getTime() async {
    try {
      // Get the current local date and time.
      DateTime now = DateTime.now();

      // Format the time string ("08:05")
      // This ensures minutes/hours are two digits
      time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // Determine if it is daytime
      dayTime = isDaytime(now);

      // Convert the weekday number to a string. (DateTime.weekday returns 1 for Monday, 7 for Sunday.)
      dayOfWeek = daysOfWeek[now.weekday - 1];

    } on FormatException catch (e) {
      print("Error formatting the time: $e");
    } on Exception catch (e) {
      print("General error occurred: $e");
    } catch (e) {
      print("Unknown error: $e");
    }
  }
}
