extension DateFormatExtension on String {
  String toSimpleDate() {
    // Parse the input date string
    DateTime parsedDate = DateTime.parse(this);

    // Format the date to 'yyyy-MM-dd'
    String formattedDate =
        "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";

    return formattedDate;
  }
}
