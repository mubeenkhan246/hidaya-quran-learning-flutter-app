import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_app/utils/translation_helper.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class MemorizationScreen extends StatefulWidget {
  const MemorizationScreen({super.key});

  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, bool> _isPlaying = {};
  final Map<String, bool> _showTranslation = {};

  @override
  void dispose() {
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleVerseAudio(int surahNumber, int verseNumber) async {
    final key = '$surahNumber:$verseNumber';
    
    if (!_audioPlayers.containsKey(key)) {
      _audioPlayers[key] = AudioPlayer();
    }
    
    final player = _audioPlayers[key]!;
    
    try {
      if (_isPlaying[key] == true && player.playing) {
        await player.pause();
        setState(() {
          _isPlaying[key] = false;
        });
      } else if (player.playerState.processingState == ProcessingState.ready ||
          player.playerState.processingState == ProcessingState.completed) {
        await player.play();
        setState(() {
          _isPlaying[key] = true;
        });
      } else {
        final surahFormatted = surahNumber.toString().padLeft(3, '0');
        final verseFormatted = verseNumber.toString().padLeft(3, '0');
        final audioUrl =
            'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/$surahFormatted$verseFormatted.mp3';

        await player.setUrl(audioUrl);
        await player.play();
        setState(() {
          _isPlaying[key] = true;
        });

        player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) {
              setState(() {
                _isPlaying[key] = false;
              });
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _copyVerse(int surahNumber, int verseNumber, String arabicText) {
    final translation = _getTranslation(surahNumber, verseNumber);
    final text = '$arabicText\n\n$translation\n\n[${quran.getSurahName(surahNumber)} $surahNumber:$verseNumber]';
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verse copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareVerse(int surahNumber, int verseNumber, String arabicText) {
    final translation = _getTranslation(surahNumber, verseNumber);
    final text = '$arabicText\n\n$translation\n\n[${quran.getSurahName(surahNumber)} $surahNumber:$verseNumber]';
    // Share.share(text);
                            SharePlus.instance.share(ShareParams(text: text));

  }

  // String _getTranslation(int surahNumber, int verseNumber) {
  //   final appProvider = context.read<AppProvider>();
  //   final language = appProvider.selectedLanguage;
    
  //   switch (language) {
  //     case 'English':
  //       return 'Translation: ${quran.getVerse(surahNumber, verseNumber)}';
  //     case 'Urdu':
  //       return 'ترجمہ: ${quran.getVerse(surahNumber, verseNumber)}';
  //     case 'Bahasa Indonesia':
  //       return 'Terjemahan: ${quran.getVerse(surahNumber, verseNumber)}';
  //     default:
  //       return quran.getVerse(surahNumber, verseNumber);
  //   }
  // }

    String _getTranslation(int surahNumber, int verseNumber) {
    final appProvider = context.read<AppProvider>();
    final translationKey = appProvider.selectedTranslation;
    
    return TranslationHelper.getTranslation(
      surahNumber,
      verseNumber,
      translationKey,
    );
  }


  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final memorizedVerses = appProvider.userProgress?.memorizedVerses ?? {};
    
    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Memorization',
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your Hifz journey',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: appProvider.accentColor,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(
                        Icons.psychology_rounded,
                        color: appProvider.accentColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${memorizedVerses.length} Verses Memorized',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: appProvider.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Keep up the good work!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Memorized verses list
              memorizedVerses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 80,
                            color: isDark 
                                ? AppTheme.textLight.withOpacity(0.3)
                                : AppTheme.textDark.withOpacity(0.3),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No verses memorized yet',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: isDark 
                                      ? AppTheme.textLight.withOpacity(0.5)
                                      : AppTheme.textDark.withOpacity(0.5),
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add verses from Quran reading',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark 
                                      ? AppTheme.textLight.withOpacity(0.3)
                                      : AppTheme.textDark.withOpacity(0.3),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: memorizedVerses.length,
                      itemBuilder: (context, index) {
                        final entry = memorizedVerses.entries.elementAt(index);
                        final parts = entry.key.split(':');
                        final surahNumber = int.parse(parts[0]);
                        final verseNumber = int.parse(parts[1]);
                        
                        final surahName = quran.getSurahName(surahNumber);
                        final verseText = quran.getVerse(surahNumber, verseNumber, verseEndSymbol: true);
                        final translation = _getTranslation(surahNumber, verseNumber);
                        final key = entry.key;
                        final isPlaying = _isPlaying[key] ?? false;
                        final showTranslation = _showTranslation[key] ?? true;
                        
                        return GlassCard(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header with verse reference and controls
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: appProvider.accentColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$surahName $surahNumber:$verseNumber',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  
                                  // Translation toggle
                                  IconButton(
                                    icon: Icon(
                                      showTranslation
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      color: appProvider.accentColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showTranslation[key] = !showTranslation;
                                      });
                                    },
                                    tooltip: 'Toggle Translation',
                                  ),
                                  
                                  // More options
                                  PopupMenuButton<String>(
                                    icon:  Icon(
                                      Icons.more_vert_rounded,
                                      color: appProvider.accentColor,
                                      size: 20,
                                    ),
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'copy':
                                          _copyVerse(surahNumber, verseNumber, verseText);
                                          break;
                                        case 'share':
                                          _shareVerse(surahNumber, verseNumber, verseText);
                                          break;
                                        case 'delete':
                                          _confirmDelete(appProvider, surahNumber, verseNumber);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'copy',
                                        child: Row(
                                          children: [
                                            Icon(Icons.copy_rounded, size: 20),
                                            SizedBox(width: 12),
                                            Text('Copy'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Row(
                                          children: [
                                            Icon(Icons.share_rounded, size: 20),
                                            SizedBox(width: 12),
                                            Text('Share'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                            SizedBox(width: 12),
                                            Text('Remove', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Arabic text
                              SelectableText(
                                verseText,
                                style: AppTheme.arabicTextStyle(
                                  fontSize: 24,
                                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              
                              // Translation
                              if (showTranslation) ...[
                                const SizedBox(height: 12),
                                Divider(
                                  color: isDark 
                                      ? AppTheme.textLight.withOpacity(0.2)
                                      : AppTheme.textDark.withOpacity(0.2),
                                ),
                                const SizedBox(height: 12),
                                SelectableText(
                            translation,
                            textDirection: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextAlign.right
                                : TextAlign.left,
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                                // SelectableText(
                                //   translation,
                                //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                //         fontStyle: FontStyle.italic,
                                //       ),
                                // ),
                              ],
                              
                              const SizedBox(height: 16),
                              
                              // Play button
                              ElevatedButton.icon(
                                onPressed: () => _toggleVerseAudio(surahNumber, verseNumber),
                                icon: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                ),
                                label: Text(isPlaying ? 'Pause' : 'Play'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appProvider.accentColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _confirmDelete(
    AppProvider appProvider,
    int surahNumber,
    int verseNumber,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appProvider.isDarkMode 
            ? AppTheme.primaryDark 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Remove Verse?'),
        content: Text(
          'Are you sure you want to remove ${quran.getSurahName(surahNumber)} $surahNumber:$verseNumber from memorization?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final key = '$surahNumber:$verseNumber';
              appProvider.userProgress?.memorizedVerses.remove(key);
              appProvider.updateProgress(appProvider.userProgress!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
