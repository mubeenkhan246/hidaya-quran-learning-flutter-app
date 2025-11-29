import 'package:flutter/material.dart';
import 'package:i_app/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class AudioPlayerScreen extends StatefulWidget {
  final int surahNumber;
  
  const AudioPlayerScreen({
    super.key,
    required this.surahNumber,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  int _selectedQariIndex = 0;
  int _currentVerse = 1;
  bool _isLooping = false;
  int? _loopStart;
  int? _loopEnd;

  @override
  Widget build(BuildContext context) {
    final surahName = quran.getSurahName(widget.surahNumber);
    final versesCount = quran.getVerseCount(widget.surahNumber);
    
    return Container(
      decoration: AppTheme.gradientBackground(context.watch<AppProvider>().themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar(
          title: 'Recitation - $surahName',
          actions: [
            IconButton(
              icon: const Icon(Icons.playlist_play_rounded),
              onPressed: () {
                _showQariSelection();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildArtwork(),
                    const SizedBox(height: 32),
                    _buildCurrentQari(),
                    const SizedBox(height: 32),
                    _buildProgressSection(versesCount),
                    const SizedBox(height: 32),
                    _buildPlayerControls(),
                    const SizedBox(height: 24),
                    _buildPlaybackSpeedSelector(),
                    const SizedBox(height: 24),
                    _buildLoopControls(versesCount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appProvider.accentColor.withOpacity(0.3),
              AppTheme.secondaryDeep.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(
              Icons.headphones_rounded,
              size: 80,
              color: appProvider.accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              quran.getSurahNameArabic(widget.surahNumber),
              style: AppTheme.arabicTextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentQari() {
    final qari = AppConstants.reciters[_selectedQariIndex];
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      onTap: _showQariSelection,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appProvider.accentColor,
                  appProvider.accentColor.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qari['name']!,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  qari['arabicName']!,
                  style: AppTheme.arabicTextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                Text(
                  qari['style']!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
           Icon(
            Icons.arrow_forward_ios_rounded,
            color: appProvider.accentColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(int versesCount) {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verse $_currentVerse of $versesCount',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_isLooping)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: appProvider.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                       Icon(
                        Icons.repeat_rounded,
                        color: appProvider.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Loop: $_loopStart-$_loopEnd',
                        style:  TextStyle(
                          color: appProvider.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _currentVerse.toDouble(),
            min: 1,
            max: versesCount.toDouble(),
            divisions: versesCount - 1,
            activeColor: appProvider.accentColor,
            inactiveColor: AppTheme.textLight.withOpacity(0.2),
            onChanged: (value) {
              setState(() {
                _currentVerse = value.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    final appProvider = context.watch<AppProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            if (_currentVerse > 1) {
              setState(() => _currentVerse--);
            }
          },
          icon: const Icon(Icons.skip_previous_rounded),
          iconSize: 40,
          color: AppTheme.textLight,
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                appProvider.accentColor,
                appProvider.accentColor.withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: appProvider.accentColor.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              setState(() => _isPlaying = !_isPlaying);
              // Implement audio playback with just_audio
            },
            icon: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 40,
            ),
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            final versesCount = quran.getVerseCount(widget.surahNumber);
            if (_currentVerse < versesCount) {
              setState(() => _currentVerse++);
            }
          },
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: 40,
          color: AppTheme.textLight,
        ),
      ],
    );
  }

  Widget _buildPlaybackSpeedSelector() {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Playback Speed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.playbackSpeeds.map((speed) {
              final isSelected = _playbackSpeed == speed;
              return GestureDetector(
                onTap: () {
                  setState(() => _playbackSpeed = speed);
                },
                child: Container(
                  padding:  EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? appProvider.accentColor
                        : AppTheme.textLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${speed}x',
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.textDark
                          : AppTheme.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoopControls(int versesCount) {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repeat Range',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: _isLooping,
                onChanged: (value) {
                  setState(() {
                    _isLooping = value;
                    if (value && _loopStart == null) {
                      _loopStart = 1;
                      _loopEnd = versesCount;
                    }
                  });
                },
                activeColor: appProvider.accentColor,
              ),
            ],
          ),
          if (_isLooping) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Verse',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<int>(
                        value: _loopStart,
                        isExpanded: true,
                        dropdownColor: AppTheme.primaryDark,
                        items: List.generate(
                          versesCount,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('Verse ${index + 1}'),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _loopStart = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Verse',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<int>(
                        value: _loopEnd,
                        isExpanded: true,
                        dropdownColor: AppTheme.primaryDark,
                        items: List.generate(
                          versesCount,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('Verse ${index + 1}'),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _loopEnd = value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showQariSelection() {
    final appProvider = context.watch<AppProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Qari',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ...AppConstants.reciters.asMap().entries.map((entry) {
              final index = entry.key;
              final qari = entry.value;
              final isSelected = _selectedQariIndex == index;
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedQariIndex = index);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? appProvider.accentColor.withOpacity(0.2)
                        : AppTheme.textLight.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? appProvider.accentColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              qari['name']!,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              qari['arabicName']!,
                              style: AppTheme.arabicTextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                         Icon(
                          Icons.check_circle_rounded,
                          color: appProvider.accentColor,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
