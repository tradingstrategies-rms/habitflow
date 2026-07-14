import 'dart:convert';
import '../../../core/services/storage/storage_service.dart';
import 'habit_model.dart';

/// [LocalHabitDataSource] handles habit persistence using [StorageService].
class LocalHabitDataSource {
  LocalHabitDataSource(this._storage);

  final StorageService _storage;
  static const _habitsKey = 'habits';

  Future<List<HabitModel>> getAllHabits() async {
    final String? data = await _storage.read(_habitsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((j) => HabitModel.fromJson(j)).toList();
  }

  Future<void> saveAllHabits(List<HabitModel> habits) async {
    final String data = jsonEncode(habits.map((h) => h.toJson()).toList());
    await _storage.write(_habitsKey, data);
  }
}
