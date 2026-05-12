import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/l10n/app_localizations.dart';

class ServicerequestVoice extends ConsumerStatefulWidget {
  final String voiceUrl;
  const ServicerequestVoice({super.key, required this.voiceUrl});

  @override
  ConsumerState<ServicerequestVoice> createState() => _ServicerequestVoiceState();
}

class _ServicerequestVoiceState extends ConsumerState<ServicerequestVoice> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _toggleVoice() async {
    if (_audioPlayer == null) _audioPlayer = AudioPlayer();

    if (_isPlaying) {
      await _audioPlayer!.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer!.play(UrlSource(widget.voiceUrl));
      setState(() => _isPlaying = true);

      _audioPlayer!.onPlayerComplete.listen((event) {
        setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleVoice,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.voiceNote,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Row(
            children: [
              Text(
                _isPlaying
                    ? AppLocalizations.of(context)!.playing
                    : AppLocalizations.of(context)!.tapToPlay,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
