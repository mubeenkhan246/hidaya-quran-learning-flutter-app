import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 0)
class UserProgress {
  @HiveField(0)
  int totalStudyTime; // in seconds
  
  @HiveField(1)
  int currentStreak; // days
  
  @HiveField(2)
  int longestStreak; // days
  
  @HiveField(3)
  DateTime? lastStudyDate;
  
  @HiveField(4)
  int dailyGoal; // in minutes
  
  @HiveField(5)
  Map<String, int> surahProgress; // surahNumber -> lastAyahRead
  
  @HiveField(6)
  List<String> completedTajweedLessons;
  
  @HiveField(7)
  Map<String, int> memorizedVerses; // "surahNumber:ayahNumber" -> proficiency (1-5)
  
  @HiveField(8)
  List<String> bookmarkedVerses; // "surahNumber:ayahNumber"
  
  @HiveField(9)
  List<Achievement> achievements;
  
  @HiveField(10)
  DateTime createdAt;
  
  @HiveField(11)
  Map<String, int> dhikrCompletions; // "dhikr_name" -> total completions

  UserProgress({
    this.totalStudyTime = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.dailyGoal = 15,
    Map<String, int>? surahProgress,
    List<String>? completedTajweedLessons,
    Map<String, int>? memorizedVerses,
    List<String>? bookmarkedVerses,
    List<Achievement>? achievements,
    DateTime? createdAt,
    Map<String, int>? dhikrCompletions,
  })  : surahProgress = surahProgress ?? {},
        completedTajweedLessons = completedTajweedLessons ?? [],
        memorizedVerses = memorizedVerses ?? {},
        bookmarkedVerses = bookmarkedVerses ?? [],
        achievements = achievements ?? [],
        createdAt = createdAt ?? DateTime.now(),
        dhikrCompletions = dhikrCompletions ?? {};

  // Update streak based on last study date
  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastStudyDate != null) {
      final lastStudy = DateTime(
        lastStudyDate!.year,
        lastStudyDate!.month,
        lastStudyDate!.day,
      );
      
      final difference = today.difference(lastStudy).inDays;
      
      if (difference == 0) {
        // Same day, no change
        return;
      } else if (difference == 1) {
        // Consecutive day
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        // Streak broken
        currentStreak = 1;
      }
    } else {
      // First study session
      currentStreak = 1;
      longestStreak = 1;
    }
    
    lastStudyDate = now;
  }
  
  // Add study time
  void addStudyTime(int seconds) {
    totalStudyTime += seconds;
    updateStreak();
  }
  
  // Check if daily goal is met
  bool isDailyGoalMet() {
    if (lastStudyDate == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudy = DateTime(
      lastStudyDate!.year,
      lastStudyDate!.month,
      lastStudyDate!.day,
    );
    
    if (today != lastStudy) return false;
    
    // Get today's study time (simplified - in real app, track daily)
    return totalStudyTime >= (dailyGoal * 60);
  }
  
  // Add dhikr completion (number of times completed, not total count)
  void addDhikrCompletion(String dhikrName, int completions) {
    dhikrCompletions[dhikrName] = (dhikrCompletions[dhikrName] ?? 0) + completions;
  }
  
  // Get dhikr completion count (number of times user completed this dhikr)
  int getDhikrCompletions(String dhikrName) {
    return dhikrCompletions[dhikrName] ?? 0;
  }
}

@HiveType(typeId: 1)
class Achievement {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  String iconName;
  
  @HiveField(4)
  DateTime unlockedAt;
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.unlockedAt,
  });
}

// Predefined Achievements
class Achievements {
  static List<Map<String, dynamic>> getAll() {
    return [
      {
        'id': 'first_day',
        'title': 'First Steps',
        'description': 'Complete your first study session',
        'iconName': '🌟',
        'requirement': 'Study for the first time',
      },
      {
        'id': 'week_streak',
        'title': '7-Day Streak',
        'description': 'Study for 7 consecutive days',
        'iconName': '🔥',
        'requirement': 'Maintain a 7-day streak',
      },
      {
        'id': 'month_streak',
        'title': 'Dedicated Learner',
        'description': 'Study for 30 consecutive days',
        'iconName': '⭐',
        'requirement': 'Maintain a 30-day streak',
      },
      {
        'id': 'first_juz',
        'title': 'Juz Complete',
        'description': 'Complete reading the first Juz',
        'iconName': '📖',
        'requirement': 'Finish Juz 1',
      },
      {
        'id': 'tajweed_master',
        'title': 'Tajweed Scholar',
        'description': 'Complete all Tajweed lessons',
        'iconName': '🎓',
        'requirement': 'Complete all Tajweed courses',
      },
      {
        'id': 'memorization_start',
        'title': 'Hafiz Journey',
        'description': 'Memorize your first verse',
        'iconName': '💚',
        'requirement': 'Memorize 1 verse',
      },
      {
        'id': 'hundred_hours',
        'title': 'Century of Knowledge',
        'description': 'Accumulate 100 hours of study',
        'iconName': '⏱️',
        'requirement': '100 hours total study time',
      },
    ];
  }
}
