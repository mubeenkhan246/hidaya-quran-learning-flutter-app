class IslamicStory {
  final String id;
  final String title;
  final String? titleUrdu;
  final String titleArabic;
  final String category;
  final String story;
  final String? storyUrdu;
  final String reference;
  final String? moralLesson;
  final String? moralLessonUrdu;
  final List<String>? keyPoints;
  final List<String>? keyPointsUrdu;

  IslamicStory({
    required this.id,
    required this.title,
    this.titleUrdu,
    required this.titleArabic,
    required this.category,
    required this.story,
    this.storyUrdu,
    required this.reference,
    this.moralLesson,
    this.moralLessonUrdu,
    this.keyPoints,
    this.keyPointsUrdu,
  });
  
  String getTitle(String language) {
    if (language == 'urdu' && titleUrdu != null) {
      return titleUrdu!;
    }
    return title;
  }
  
  String getStory(String language) {
    if (language == 'urdu' && storyUrdu != null) {
      return storyUrdu!;
    }
    return story;
  }
  
  String? getMoralLesson(String language) {
    if (language == 'urdu' && moralLessonUrdu != null) {
      return moralLessonUrdu;
    }
    return moralLesson;
  }
  
  List<String>? getKeyPoints(String language) {
    if (language == 'urdu' && keyPointsUrdu != null) {
      return keyPointsUrdu;
    }
    return keyPoints;
  }
}

class StoryCategory {
  final String id;
  final String name;
  final String icon;
  final String description;

  StoryCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}
