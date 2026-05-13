import 'package:shared_preferences/shared_preferences.dart';

/// Service para rastrear dias consecutivos de uso (streaks).
/// Usa SharedPreferences para persistir dados entre sessões.
class StreakService {
  static const String _lastActiveDateKey = 'streak_last_active_date';
  static const String _currentStreakKey = 'streak_current';
  static const String _bestStreakKey = 'streak_best';

  /// Registra atividade do dia atual e atualiza o streak.
  static Future<int> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());
    final lastActiveStr = prefs.getString(_lastActiveDateKey);
    int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    int bestStreak = prefs.getInt(_bestStreakKey) ?? 0;

    if (lastActiveStr != null) {
      final lastActive = DateTime.parse(lastActiveStr);
      final diff = today.difference(lastActive).inDays;

      if (diff == 0) {
        // Já registrou hoje, sem alteração
        return currentStreak;
      } else if (diff == 1) {
        // Dia consecutivo
        currentStreak++;
      } else {
        // Quebrou o streak
        currentStreak = 1;
      }
    } else {
      // Primeiro uso
      currentStreak = 1;
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
      await prefs.setInt(_bestStreakKey, bestStreak);
    }

    await prefs.setString(_lastActiveDateKey, today.toIso8601String());
    await prefs.setInt(_currentStreakKey, currentStreak);

    return currentStreak;
  }

  /// Retorna o streak atual.
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveStr = prefs.getString(_lastActiveDateKey);
    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;

    if (lastActiveStr == null) return 0;

    final lastActive = DateTime.parse(lastActiveStr);
    final today = _dateOnly(DateTime.now());
    final diff = today.difference(lastActive).inDays;

    // Se mais de 1 dia passou, streak resetado
    if (diff > 1) return 0;

    return currentStreak;
  }

  /// Retorna o melhor streak registrado.
  static Future<int> getBestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestStreakKey) ?? 0;
  }

  static DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }
}
