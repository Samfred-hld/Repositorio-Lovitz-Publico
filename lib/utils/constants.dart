class ApiConstants {
  static const String baseUrl =
      'https://maslow-progress-70d3dad7.base44.app/api';
  static const String apiKey = '813c92bd6bac4b0db5cd42fdf17dee33';
  static const String appId = '68a771320ec4ba9670d3dad7';

  // Endpoints
  static const String habits = '/entities/Habit';
  static const String habitRecords = '/entities/HabitRecord';
  static const String achievements = '/entities/Achievement';
  static const String journalEntries = '/entities/JournalEntry';
  static const String users = '/entities/User';
}

class MaslowLevels {
  static const int physiologic = 1;  // Necessidades fisiológicas
  static const int safety = 2;       // Segurança
  static const int social = 3;       // Social
  static const int esteem = 4;       // Estima
  static const int selfActualization = 5; // Autorrealização

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
