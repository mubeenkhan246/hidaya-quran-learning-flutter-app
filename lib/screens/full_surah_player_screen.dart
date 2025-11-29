import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:just_audio/just_audio.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../utils/translation_helper.dart';

enum SurahPlayMode {
  continuousWithDisplay, // Play full surah with verse display
  verseByVerse, // Play verse by verse with auto-advance
}

class FullSurahPlayerScreen extends StatefulWidget {
  final int surahNumber;
  final SurahPlayMode playMode;

  const FullSurahPlayerScreen({
    super.key,
    required this.surahNumber,
    this.playMode = SurahPlayMode.continuousWithDisplay,
  });

  @override
  State<FullSurahPlayerScreen> createState() => _FullSurahPlayerScreenState();
}

class _FullSurahPlayerScreenState extends State<FullSurahPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentVerse = 1;
  int _totalVerses = 0;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  ConcatenatingAudioSource? _playlist;

  @override
  void initState() {
    super.initState();
    _totalVerses = quran.getVerseCount(widget.surahNumber);
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      
      setState(() {
        _isPlaying = state.playing;
        _isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });

      // Handle completion
      if (state.processingState == ProcessingState.completed) {
        print('=== COMPLETION EVENT FIRED ===');
        print('Play mode: ${widget.playMode}');
        
        if (widget.playMode == SurahPlayMode.continuousWithDisplay) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Surah completed!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else if (widget.playMode == SurahPlayMode.verseByVerse) {
          // For verse-by-verse, completion handled by current index listener
          if (_currentVerse >= _totalVerses && mounted) {
            print('✓ Surah completed!');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Surah completed!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    });

    // Listen to position
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Listen to duration
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen to current index for playlist mode
    if (widget.playMode == SurahPlayMode.verseByVerse) {
      _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
        if (!mounted || index == null) return;
        
        print('=== CURRENT INDEX CHANGED TO: $index ===');
        final newVerse = index + 1; // Convert 0-based index to 1-based verse
        
        if (newVerse != _currentVerse) {
          setState(() {
            _currentVerse = newVerse;
          });
          print('✓ Current verse updated to: $_currentVerse');
          
          // Preload next verses if needed
          _preloadNextVerses();
        }
      });
    }

    // Load audio based on play mode
    if (widget.playMode == SurahPlayMode.continuousWithDisplay) {
      _loadFullSurahAudio();
    } else {
      _loadVersePlaylist();
    }
  }

  Future<void> _loadFullSurahAudio() async {
    try {
      print('=== FULL SURAH AUDIO DEBUG START ===');
      
      setState(() {
        _isLoading = true;
      });

      // Get selected reciter from AppProvider
      final appProvider = context.read<AppProvider>();
      final reciterKey = appProvider.selectedReciter;
      
      print('Surah Number: ${widget.surahNumber}');
      print('Selected Reciter Key: $reciterKey');

      // Get full Surah audio URL using translation helper
      final audioUrl =
       TranslationHelper.getFullSurahAudioUrl(
        widget.surahNumber,
        reciterKey,
      );

      // Debug: Print the URL being loaded
      print('Audio URL: $audioUrl');

      // Set audio source with better error handling
      print('Setting audio URL...');
      final duration = await _audioPlayer.setUrl(audioUrl);
      print('Audio URL set successfully. Duration: $duration');
      
      // Start playing
      print('Starting playback...');
      await _audioPlayer.play();
      print('Playback started successfully');

      setState(() {
        _isLoading = false;
      });
      
      print('=== FULL SURAH AUDIO DEBUG SUCCESS ===');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio loaded successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('=== FULL SURAH AUDIO DEBUG ERROR ===');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadFullSurahAudio,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadVersePlaylist() async {
    try {
      print('=== LOADING VERSE PLAYLIST ===');
      
      setState(() {
        _isLoading = true;
      });

      final appProvider = context.read<AppProvider>();
      final reciterKey = appProvider.selectedReciter;
      
      // Create playlist with first 3 verses (or all if less than 3)
      final initialVerseCount = _totalVerses < 3 ? _totalVerses : 3;
      final audioSources = <AudioSource>[];
      
      for (int i = 1; i <= initialVerseCount; i++) {
        final audioUrl = TranslationHelper.getVerseAudioUrl(
          widget.surahNumber,
          i,
          reciterKey,
        );
        audioSources.add(AudioSource.uri(Uri.parse(audioUrl)));
        print('Added verse $i to playlist: $audioUrl');
      }
      
      _playlist = ConcatenatingAudioSource(children: audioSources);
      
      await _audioPlayer.setAudioSource(_playlist!);
      print('✓ Playlist loaded with $initialVerseCount verses');
      
      // Start playing
      await _audioPlayer.play();
      
      setState(() {
        _isLoading = false;
      });
      
      print('✓ Playback started successfully');
    } catch (e, stackTrace) {
      print('Error loading verse playlist: $e');
      print('Stack trace: $stackTrace');
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading playlist: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _preloadNextVerses() async {
    if (_playlist == null) return;
    
    try {
      final appProvider = context.read<AppProvider>();
      final reciterKey = appProvider.selectedReciter;
      
      // Calculate how many verses we need to add
      final currentPlaylistLength = _playlist!.length;
      final versesToPreload = _currentVerse + 3; // Keep 3 verses ahead
      
      if (versesToPreload > currentPlaylistLength && versesToPreload <= _totalVerses) {
        print('Preloading verses ${currentPlaylistLength + 1} to $versesToPreload');
        
        for (int i = currentPlaylistLength + 1; i <= versesToPreload && i <= _totalVerses; i++) {
          final audioUrl = TranslationHelper.getVerseAudioUrl(
            widget.surahNumber,
            i,
            reciterKey,
          );
          await _playlist!.add(AudioSource.uri(Uri.parse(audioUrl)));
          print('✓ Preloaded verse $i');
        }
      }
    } catch (e) {
      print('Error preloading verses: $e');
    }
  }

  Future<void> _loadVerseAudio(int verseNumber) async {
    // This method is now only used for manual navigation
    if (_playlist == null) return;
    
    try {
      print('Seeking to verse $verseNumber');
      
      final targetIndex = verseNumber - 1; // Convert to 0-based index
      
      if (targetIndex >= 0 && targetIndex < _playlist!.length) {
        await _audioPlayer.seek(Duration.zero, index: targetIndex);
        if (!_isPlaying) {
          await _audioPlayer.play();
        }
      } else {
        print('Verse $verseNumber not in playlist yet, rebuilding...');
        // Rebuild playlist if needed
        await _loadVersePlaylist();
      }
    } catch (e) {
      print('Error loading verse $verseNumber: $e');
    }
  }

  Future<void> _playNextVerse() async {
    if (_currentVerse < _totalVerses) {
      await _loadVerseAudio(_currentVerse + 1);
    }
  }

  Future<void> _playPreviousVerse() async {
    if (_currentVerse > 1) {
      await _loadVerseAudio(_currentVerse - 1);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.processingState == ProcessingState.completed) {
        // Restart from beginning if completed
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    }
  }

  Future<void> _seekForward() async {
    final newPosition = _position + const Duration(seconds: 10);
    if (newPosition < _duration) {
      await _audioPlayer.seek(newPosition);
    } else {
      await _audioPlayer.seek(_duration);
    }
  }

  Future<void> _seekBackward() async {
    final newPosition = _position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      await _audioPlayer.seek(newPosition);
    } else {
      await _audioPlayer.seek(Duration.zero);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    print('Disposing audio player and subscriptions');
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final surahName = quran.getSurahName(widget.surahNumber);
    final surahNameArabic = quran.getSurahNameArabic(widget.surahNumber);
    final totalVerses = quran.getVerseCount(widget.surahNumber);
    final revelationType = quran.getPlaceOfRevelation(widget.surahNumber);

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            children: [
              Text(surahName),
              Text(
                widget.playMode == SurahPlayMode.verseByVerse
                    ? 'Verse by Verse'
                    : 'Continuous Play',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Surah info card
                GlassCard(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        // Album art style circle
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                appProvider.accentColor,
                                appProvider.accentColor.withOpacity(0.6),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: appProvider.accentColor.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isPlaying 
                                      ? Icons.graphic_eq_rounded 
                                      : Icons.graphic_eq_rounded,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.surahNumber.toString(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          surahNameArabic,
                          style: AppTheme.arabicTextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          surahName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: appProvider.accentColor,
                              ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          '$totalVerses Verses • $revelationType',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Current verse display
                GlassCard(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Verse number indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: appProvider.accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: appProvider.accentColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                widget.playMode == SurahPlayMode.verseByVerse
                                    ? 'Verse $_currentVerse of $_totalVerses'
                                    : 'Full Surah',
                                style: TextStyle(
                                  color: appProvider.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        if (widget.playMode == SurahPlayMode.verseByVerse) ...[
                          const SizedBox(height: 20),
                          
                          // Arabic verse text
                          Text(
                            quran.getVerse(widget.surahNumber, _currentVerse, verseEndSymbol: true),
                            style: AppTheme.arabicTextStyle(
                              fontSize: appProvider.arabicTextSize,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              height: 1.9,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Translation
                          Text(
                            TranslationHelper.getTranslation(
                              widget.surahNumber,
                              _currentVerse,
                              appProvider.selectedTranslation,
                            ),
                            style: TextStyle(
                              fontSize: appProvider.translationFontSize,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Progress bar
                GlassCard(
                  child: Column(
                    children: [
                      Slider(
                        value: _position.inSeconds.toDouble(),
                        max: _duration.inSeconds.toDouble() > 0
                            ? _duration.inSeconds.toDouble()
                            : 1.0,
                        activeColor: appProvider.accentColor,
                        inactiveColor: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.2),
                        onChanged: (value) async {
                          await _audioPlayer.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Playback controls
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous verse / Rewind
                      IconButton(
                        icon: Icon(
                          widget.playMode == SurahPlayMode.verseByVerse
                              ? Icons.skip_previous_rounded
                              : Icons.replay_10_rounded,
                        ),
                        iconSize: 40,
                        color: widget.playMode == SurahPlayMode.verseByVerse && _currentVerse <= 1
                            ? appProvider.accentColor.withOpacity(0.3)
                            : appProvider.accentColor,
                        onPressed: widget.playMode == SurahPlayMode.verseByVerse
                            ? (_currentVerse > 1 ? _playPreviousVerse : null)
                            : _seekBackward,
                        tooltip: widget.playMode == SurahPlayMode.verseByVerse
                            ? 'Previous Verse'
                            : 'Rewind 10 seconds',
                      ),

                      // Play/Pause
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appProvider.accentColor,
                          boxShadow: [
                            BoxShadow(
                              color: appProvider.accentColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                                iconSize: 48,
                                color: Colors.white,
                                onPressed: _togglePlayPause,
                              ),
                      ),

                      // Next verse / Forward
                      IconButton(
                        icon: Icon(
                          widget.playMode == SurahPlayMode.verseByVerse
                              ? Icons.skip_next_rounded
                              : Icons.forward_10_rounded,
                        ),
                        iconSize: 40,
                        color: widget.playMode == SurahPlayMode.verseByVerse && _currentVerse >= _totalVerses
                            ? appProvider.accentColor.withOpacity(0.3)
                            : appProvider.accentColor,
                        onPressed: widget.playMode == SurahPlayMode.verseByVerse
                            ? (_currentVerse < _totalVerses ? _playNextVerse : null)
                            : _seekForward,
                        tooltip: widget.playMode == SurahPlayMode.verseByVerse
                            ? 'Next Verse'
                            : 'Forward 10 seconds',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Status text
                if (_isLoading)
                  Text(
                    widget.playMode == SurahPlayMode.verseByVerse
                        ? 'Loading Verse $_currentVerse...'
                        : 'Loading Surah...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: appProvider.accentColor,
                        ),
                  )
                else if (_isPlaying)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volume_up_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.playMode == SurahPlayMode.verseByVerse
                            ? 'Playing Verse $_currentVerse'
                            : 'Playing Full Surah',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: appProvider.accentColor,
                            ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Ready to play',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textLight.withOpacity(0.5)
                              : AppTheme.textDark.withOpacity(0.5),
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
