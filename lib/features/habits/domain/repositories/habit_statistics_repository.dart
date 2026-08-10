abstract class HabitStatisticsRepository {
  Future<int> getCurrentStreak(String habitId);
  
  Future<int> getLongestStreak(String habitId);
  
  Future<double> getCompletionPercentage(String habitId, DateTime start, DateTime end);
  
  Future<Map<String, dynamic>> getWeeklySummary(String habitId);
  
  Future<Map<String, dynamic>> getMonthlySummary(String habitId);
  
  Future<List<Map<String, dynamic>>> getHeatmapData(String habitId, int year);
  
  Future<Map<String, dynamic>> getDashboardMetrics();
}
