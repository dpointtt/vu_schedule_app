class EventsDateUtils{
  static bool isEventNow(DateTime eventStart, DateTime eventEnd) {
    final now = DateTime.now();

    return now.isAfter(eventStart) &&
        now.isBefore(eventEnd);
  }

  static bool isBreakNow(DateTime previousEventEnd, DateTime nextEventStart) {
    final now = DateTime.now();

    return now.isAfter(previousEventEnd) &&
        now.isBefore(nextEventStart);
  }
}