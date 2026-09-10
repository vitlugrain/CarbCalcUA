import 'package:flutter/foundation.dart';

/// Carries an explicit "add to this meal" request from Diary to Add Food
/// without changing the existing meal grouping rules.
class MealAddTarget {
  final String groupId;
  final String meal;
  final String date;
  final String time;

  const MealAddTarget({
    required this.groupId,
    required this.meal,
    required this.date,
    required this.time,
  });
}

class MealEditCoordinator {
  static final ValueNotifier<MealAddTarget?> addTarget =
      ValueNotifier<MealAddTarget?>(null);

  static void requestAdd(MealAddTarget target) {
    addTarget.value = target;
  }

  static MealAddTarget? consumeAddTarget() {
    final value = addTarget.value;
    addTarget.value = null;
    return value;
  }
}
