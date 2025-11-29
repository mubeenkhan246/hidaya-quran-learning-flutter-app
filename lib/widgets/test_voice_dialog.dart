import 'package:flutter/material.dart';
import 'package:i_app/providers/app_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../utils/translation_helper.dart';

class TestVoiceDialog extends StatefulWidget {
  final String reciterKey;
  final String reciterName;

  const TestVoiceDialog({
    super.key,
    required this.reciterKey,
    required this.reciterName,
  });

  @override
  State<TestVoiceDialog> createState() => _TestVoiceDialogState();
}

class _TestVoiceDialogState extends State<TestVoiceDialog> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTestVerse() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Play Al-Fatihah (Surah 1) as test
      final audioUrl = TranslationHelper.getVerseAudioUrl(
        1, // Al-Fatihah
        1, // First verse
        widget.reciterKey,
      );

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    return AlertDialog(
      backgroundColor: appProvider.isDarkMode 
                ? AppTheme.primaryDark 
                : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
           Icon(Icons.record_voice_over_rounded, color: appProvider.accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Test Voice',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.reciterName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: appProvider.accentColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
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
                    padding: EdgeInsets.all(25),
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
                    onPressed: () {
                      if (_isPlaying) {
                        _audioPlayer.pause();
                      } else {
                        _playTestVerse();
                      }
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            'Al-Fatihah • Verse 1',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _audioPlayer.stop();
            Navigator.pop(context);
          },
          child: Text('Close', style: TextStyle(color: appProvider.accentColor)),
        ),
      ],
    );
  }
}
