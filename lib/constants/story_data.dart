import '../models/islamic_story.dart';

class StoryData {
  static final List<StoryCategory> categories = [
    StoryCategory(
      id: 'prophets',
      name: 'Stories of Prophets',
      icon: '📕',
      description: 'Learn from the lives of Allah\'s messengers',
    ),
    StoryCategory(
      id: 'quran',
      name: 'Quranic Stories',
      icon: '📖',
      description: 'Stories mentioned in the Holy Quran',
    ),
    StoryCategory(
      id: 'hadith',
      name: 'Hadith Stories',
      icon: '📚',
      description: 'Inspiring stories from Hadith',
    ),
    StoryCategory(
      id: 'companions',
      name: 'Companions Stories',
      icon: '🕌',
      description: 'Stories of the Sahaba',
    ),
  ];

  static final List<IslamicStory> stories = [
    // Prophet Stories
    IslamicStory(
      id: 'prophet_ibrahim',
      title: 'Prophet Ibrahim and His Son',
      titleArabic: 'إبراهيم عليه السلام وابنه',
      category: 'prophets',
      story: '''Prophet Ibrahim (AS) was tested by Allah when he saw a dream commanding him to sacrifice his beloved son Ismail (AS). This was the ultimate test of faith and submission to Allah's will.

Both father and son showed exemplary obedience. When Ibrahim told Ismail about the dream, Ismail responded with complete submission: "O my father, do as you are commanded. You will find me, if Allah wills, of the steadfast."

As Ibrahim was about to sacrifice his son, Allah replaced Ismail with a ram, showing that the test was about their willingness to submit, not the actual sacrifice. This event is commemorated during Eid al-Adha.''',
      reference: 'Surah As-Saffat (37:99-111)',
      moralLesson: 'Complete submission to Allah\'s will and trust in His wisdom, even in the most difficult tests.',
      keyPoints: [
        'True faith means putting Allah\'s commands above all else',
        'Patience and submission in trials',
        'Allah never burdens a soul beyond its capacity',
        'Obedience to parents in righteousness',
      ],
    ),
    IslamicStory(
      id: 'prophet_yusuf',
      title: 'Prophet Yusuf in the Well',
      titleArabic: 'يوسف عليه السلام في البئر',
      category: 'prophets',
      story: '''Prophet Yusuf (AS) was the beloved son of Prophet Yaqub (AS). His brothers became jealous of their father's love for him and plotted against him. They threw young Yusuf into a deep well and told their father that a wolf had killed him.

Despite being betrayed by his own brothers and thrown into darkness, Yusuf never lost faith in Allah. He was later rescued by a caravan and sold as a slave in Egypt. Through all his trials - from slavery to false accusation to imprisonment - Yusuf remained patient and righteous.

Eventually, Allah elevated him to become the treasurer of Egypt, and he was reunited with his family. He forgave his brothers, showing that patience and righteousness always lead to victory.''',
      reference: 'Surah Yusuf (12:1-111)',
      moralLesson: 'Patience in adversity, forgiveness, and trust that Allah has a plan even in our darkest moments.',
      keyPoints: [
        'Jealousy leads to harm',
        'Patience in trials brings reward',
        'Forgiveness is better than revenge',
        'Allah\'s plan unfolds in His perfect timing',
      ],
    ),
    IslamicStory(
      id: 'prophet_musa_khidr',
      title: 'Prophet Musa and Al-Khidr',
      titleArabic: 'موسى والخضر عليهما السلام',
      category: 'prophets',
      story: '''Prophet Musa (AS) was once asked who was the most knowledgeable person. He replied that he was, thinking he knew the most. Allah informed him about Al-Khidr, a servant of Allah with special knowledge. Musa traveled to meet him and requested to accompany him to learn.

Al-Khidr agreed on the condition that Musa would not question his actions. During their journey, Al-Khidr did three things that seemed wrong: damaged a boat, killed a young boy, and repaired a wall in an unwelcoming town.

Musa questioned each action, breaking his promise. Finally, Al-Khidr explained: the boat belonged to poor people, and he damaged it to save it from a king who was seizing every boat. The boy would have caused his righteous parents grief, and Allah would give them a better child. The wall belonged to two orphans with treasure underneath, which would have been stolen if not repaired.''',
      reference: 'Surah Al-Kahf (18:60-82)',
      moralLesson: 'Divine wisdom is beyond human understanding. What seems bad might be good, and what seems good might be bad.',
      keyPoints: [
        'Allah\'s wisdom is infinite',
        'Don\'t judge situations without full knowledge',
        'Humility in seeking knowledge',
        'Trust in Allah\'s perfect plan',
      ],
    ),
    IslamicStory(
      id: 'prophet_ayub',
      title: 'Prophet Ayub\'s Patience',
      titleArabic: 'صبر أيوب عليه السلام',
      category: 'prophets',
      story: '''Prophet Ayub (AS) was a wealthy and righteous man blessed with family, health, and prosperity. Allah tested him by taking away his wealth, his children, and afflicting him with a severe illness that lasted many years.

Despite losing everything, Ayub never complained about Allah. He remained patient and continued to praise Allah. Many people abandoned him, but his faith never wavered. He only called upon Allah saying, "Indeed, adversity has touched me, and You are the Most Merciful of the merciful."

Allah was pleased with his patience and restored his health, wealth, and gave him double of what he had lost. His story became a symbol of patience and perseverance.''',
      reference: 'Surah Al-Anbiya (21:83-84), Surah Sad (38:41-44)',
      moralLesson: 'True patience means remaining grateful to Allah in both prosperity and adversity.',
      keyPoints: [
        'Patience in hardship is a form of worship',
        'Trials are tests of faith',
        'Never give up on Allah\'s mercy',
        'Gratitude in all circumstances',
      ],
    ),

    // Quranic Stories
    IslamicStory(
      id: 'people_cave',
      title: 'The People of the Cave',
      titleArabic: 'أصحاب الكهف',
      category: 'quran',
      story: '''A group of young believers fled from a tyrannical king who wanted to force them to worship idols. They sought refuge in a cave and prayed to Allah for guidance and protection.

Allah caused them to fall into a deep sleep that lasted for 309 years. When they woke up, they thought they had slept only a day or part of a day. One of them went to the city to buy food, only to discover that centuries had passed and their entire society had changed.

Allah made their story known to show His power over life and death, and to strengthen the faith of believers. Their dog also remained with them throughout this miracle, showing Allah\'s mercy extends to all His creation.''',
      reference: 'Surah Al-Kahf (18:9-26)',
      moralLesson: 'Standing firm on faith, even when it means leaving comfort. Allah protects those who trust in Him.',
      keyPoints: [
        'Faith requires courage and sacrifice',
        'Allah\'s power over time and life',
        'True companionship in faith',
        'Divine protection for believers',
      ],
    ),
    IslamicStory(
      id: 'elephant_army',
      title: 'The Army with the Elephant',
      titleArabic: 'أصحاب الفيل',
      category: 'quran',
      story: '''Abraha, the ruler of Yemen, built a magnificent church and wanted to divert the Arab pilgrimage from the Kaaba to his church. When this failed, he decided to destroy the Kaaba itself.

He assembled a large army with elephants and marched toward Makkah. The elephant leading the army, named Mahmud, refused to move toward the Kaaba, kneeling down instead. However, when turned in any other direction, it would walk.

Allah sent flocks of birds (Ababil) carrying stones of sijjil (baked clay). They pelted the army, destroying them completely. This event occurred in the year Prophet Muhammad (ﷺ) was born, known as the Year of the Elephant.''',
      reference: 'Surah Al-Fil (105:1-5)',
      moralLesson: 'Allah protects His sacred house and will defend His religion, even through unexpected means.',
      keyPoints: [
        'Allah\'s house is sacred and protected',
        'Arrogance leads to destruction',
        'Allah\'s power manifests in miraculous ways',
        'Divine protection of Islam',
      ],
    ),

    // Hadith Stories  
    IslamicStory(
      id: 'man_dog',
      title: 'The Man Who Gave Water to a Dog',
      titleArabic: 'الرجل الذي سقى الكلب',
      category: 'hadith',
      story: '''A man was walking on a very hot day and became extremely thirsty. He found a well, went down into it, drank water, and came out. Then he saw a dog panting and licking mud because of extreme thirst.

The man said to himself, "This dog is suffering from thirst as I was suffering from it." He went down the well again, filled his shoe with water, held it in his mouth, climbed up, and gave the dog water to drink.

Allah thanked him for that deed and forgave his sins. The companions asked, "O Messenger of Allah, is there a reward for us in serving animals?" He replied, "There is a reward for serving any living being."''',
      reference: 'Sahih Bukhari 2466, Sahih Muslim 2244',
      moralLesson: 'Showing mercy to all of Allah\'s creation, even animals, is rewarded by Allah.',
      keyPoints: [
        'Kindness to animals is rewarded',
        'Small acts of mercy matter',
        'Compassion is a core Islamic value',
        'Every living being deserves kindness',
      ],
    ),
    IslamicStory(
      id: 'woman_cat',
      title: 'The Woman Punished for a Cat',
      titleArabic: 'المرأة والهرة',
      category: 'hadith',
      story: '''The Prophet Muhammad (ﷺ) told his companions about a woman who was punished severely in the afterlife because of her treatment of a cat.

She locked up a cat, neither feeding it nor allowing it to go free and eat from the insects of the earth. The cat died of starvation, and because of this cruelty, the woman was thrown into Hellfire.

This hadith shows that while the woman may have prayed and fasted, her cruelty to a helpless animal was so severe that it led to her punishment. It emphasizes that Islam cares about how we treat all of Allah\'s creation.''',
      reference: 'Sahih Bukhari 3482, Sahih Muslim 2242',
      moralLesson: 'Cruelty to animals is a major sin. We are accountable for how we treat all living beings.',
      keyPoints: [
        'Animal cruelty is strictly forbidden',
        'Accountability for our actions',
        'Justice extends to all creatures',
        'Mercy is an essential quality',
      ],
    ),
    IslamicStory(
      id: 'prostitute_forgiven',
      title: 'The Woman Who Was Forgiven',
      titleArabic: 'المرأة التي غفر لها',
      category: 'hadith',
      story: '''The Prophet (ﷺ) narrated the story of a woman of ill repute who was walking on a road during a very hot day. She saw a dog near a well, panting with its tongue hanging out due to severe thirst. The dog was about to die.

She felt compassion for the animal. Despite her sinful life, she took off her leather sock, tied it to her head cover, drew some water from the well, and gave it to the dog. The dog drank and was saved.

Because of this single act of kindness, Allah forgave all her sins. The companions were amazed that someone so sinful could be forgiven. This shows Allah\'s infinite mercy and that a single good deed done with sincerity can erase a lifetime of sins.''',
      reference: 'Sahih Bukhari 3467, Sahih Muslim 2245',
      moralLesson: 'Allah\'s mercy is vast. A single sincere act of kindness can earn His forgiveness.',
      keyPoints: [
        'Never despair of Allah\'s mercy',
        'One good deed can change everything',
        'Sincerity matters more than quantity',
        'Allah values compassion highly',
      ],
    ),

    // Companions Stories
    IslamicStory(
      id: 'abu_bakr_cave',
      title: 'Abu Bakr in the Cave',
      titleArabic: 'أبو بكر في الغار',
      category: 'companions',
      story: '''When the Prophet Muhammad (ﷺ) and Abu Bakr (RA) were fleeing Makkah to Madinah, they hid in the Cave of Thawr. The Quraysh were pursuing them and reached the very entrance of the cave.

Abu Bakr became worried and said, "O Messenger of Allah! If one of them looks under his feet, he will see us." The Prophet (ﷺ) replied with complete trust in Allah: "What do you think about two, with Allah as the third?"

Allah sent a spider to spin a web over the cave entrance and a dove to make a nest. When the pursuers saw this, they assumed no one could have entered recently and left. This is referred to in the Quran as Allah's tranquility descending upon them.''',
      reference: 'Surah At-Tawbah (9:40), Sahih Bukhari 3653',
      moralLesson: 'Complete trust in Allah brings peace even in the most dangerous situations.',
      keyPoints: [
        'Trust in Allah above all',
        'Allah protects His believers',
        'True companionship in faith',
        'Peace comes from faith',
      ],
    ),
    IslamicStory(
      id: 'bilal_torture',
      title: 'Bilal\'s Steadfastness',
      titleArabic: 'صمود بلال',
      category: 'companions',
      story: '''Bilal ibn Rabah (RA) was an Abyssinian slave who accepted Islam in its early days. His master, Umayyah ibn Khalaf, was enraged and subjected him to severe torture to make him renounce Islam.

Bilal was taken to the scorching desert, where a huge rock was placed on his chest under the burning sun. His tormentors would beat him while demanding he reject Islam and worship their idols.

Despite the unbearable pain, Bilal would only say "Ahad, Ahad" (One, One), affirming the Oneness of Allah. His faith never wavered. Eventually, Abu Bakr (RA) purchased his freedom. Later, the Prophet (ﷺ) chose Bilal to be the first Mu'azzin (caller to prayer) in Islam.''',
      reference: 'Sahih Bukhari, Seerah literature',
      moralLesson: 'True faith stands firm regardless of torture or hardship. Allah honors those who remain steadfast.',
      keyPoints: [
        'Faith is worth any sacrifice',
        'Patience under persecution',
        'Allah elevates the steadfast',
        'Honor comes from righteousness, not status',
      ],
    ),
  ];

  static List<IslamicStory> getStoriesByCategory(String categoryId) {
    return stories.where((story) => story.category == categoryId).toList();
  }

  static List<IslamicStory> searchStories(String query) {
    final lowerQuery = query.toLowerCase();
    return stories.where((story) =>
      story.title.toLowerCase().contains(lowerQuery) ||
      (story.titleUrdu?.contains(query) ?? false) ||
      story.titleArabic.contains(query) ||
      story.story.toLowerCase().contains(lowerQuery) ||
      (story.storyUrdu?.contains(query) ?? false)
    ).toList();
  }
}
