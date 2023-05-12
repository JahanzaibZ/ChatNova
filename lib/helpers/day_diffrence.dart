// Generated from ChatGPT

int daysBetweenDates(
    int year1, int month1, int day1, int year2, int month2, int day2) {
  // Calculate the number of days in each month for the first year
  List<int> daysInMonth1 = [
    31, // January
    (year1 % 4 == 0 && year1 % 100 != 0 || year1 % 400 == 0)
        ? 29
        : 28, // February
    31, // March
    30, // April
    31, // May
    30, // June
    31, // July
    31, // August
    30, // September
    31, // October
    30, // November
    31, // December
  ];

  // Calculate the number of days in each month for the second year
  List<int> daysInMonth2 = [
    31, // January
    (year2 % 4 == 0 && year2 % 100 != 0 || year2 % 400 == 0)
        ? 29
        : 28, // February
    31, // March
    30, // April
    31, // May
    30, // June
    31, // July
    31, // August
    30, // September
    31, // October
    30, // November
    31, // December
  ];

  // Calculate the number of days between the two dates
  int daysBetween = 0;
  if (year1 == year2) {
    // If both dates are in the same year, add up the days between the two dates
    for (int month = month1; month < month2; month++) {
      daysBetween += daysInMonth1[month - 1];
    }
    daysBetween += day2 - day1;
  } else {
    // If the two dates are in different years, add up the days from the start date to the end of that year
    for (int month = month1; month <= 12; month++) {
      daysBetween += daysInMonth1[month - 1];
    }
    daysBetween -= day1;
    // Add up the days from the start of the second year to the end date
    for (int month = 1; month < month2; month++) {
      daysBetween += daysInMonth2[month - 1];
    }
    daysBetween += day2;
    // Add up the days for the years between the start and end year
    for (int year = year1 + 1; year < year2; year++) {
      daysBetween +=
          (year % 4 == 0 && year % 100 != 0 || year % 400 == 0) ? 366 : 365;
    }
  }
  return daysBetween;
}
