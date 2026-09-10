import 'package:sqflite/sqflite.dart';

/// Operations that act on a whole diary meal group rather than one food row.
/// Kept outside the UI so the same rules can be reused safely from the meal
/// header menu and future reports/import features.
class MealGroupService {
  static Future<int> updateGroup(
    DatabaseExecutor db, {
    required String groupId,
    required String date,
    required String meal,
    required String time,
  }) {
    return db.update(
      'diary',
      {
        'date': date,
        'meal': meal,
        'meal_time': time,
      },
      where: 'meal_group_id=?',
      whereArgs: [groupId],
    );
  }

  static Future<int> deleteGroup(
    DatabaseExecutor db, {
    required String groupId,
  }) {
    return db.delete(
      'diary',
      where: 'meal_group_id=?',
      whereArgs: [groupId],
    );
  }

  static Future<int> moveLegacyGroup(
    DatabaseExecutor db, {
    required String date,
    required String meal,
    required String time,
    required String newGroupId,
  }) {
    return db.update(
      'diary',
      {'meal_group_id': newGroupId},
      where: 'date=? AND meal_group_id IS NULL AND meal=? AND COALESCE(meal_time,\'\')=?',
      whereArgs: [date, meal, time],
    );
  }

  static String newGroupId(String meal) =>
      'meal_${DateTime.now().microsecondsSinceEpoch}_${meal.replaceAll(' ', '_')}';
}
