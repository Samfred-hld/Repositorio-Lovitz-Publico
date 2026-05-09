class ApiConstants {
  // Supabase
  static const String supabaseUrl = 'SUA_SUPABASE_URL';
  static const String supabaseAnonKey = 'SUA_SUPABASE_ANON_KEY';

  // Tabelas
  static const String usersTable = 'users';
  static const String habitsTable = 'habits';
  static const String habitLogsTable = 'habit_logs';
  static const String achievementsTable = 'achievements';
  static const String userAchievementsTable = 'user_achievements';
}

class MaslowLevels {
  static const int physiologic = 1;
  static const int safety = 2;
  static const int social = 3;
  static const int esteem = 4;
  static const int selfActualization = 5;

  static String getName(int level) {
    switch (level) {
      case 1:
        return 'Fisiológicas';
      case 2:
        return 'Segurança';
      case 3:
        return 'Social';
      case 4:
        return 'Estima';
      case 5:
        return 'Autorrealização';
      default:
        return 'Desconhecido';
    }
  }

  static String getEmoji(int level) {
    switch (level) {
      case 1:
        return '🍎';
      case 2:
        return '🛡️';
      case 3:
        return '❤️';
      case 4:
        return '⭐';
      case 5:
        return '🌟';
      default:
        return '❓';
    }
  }
}
