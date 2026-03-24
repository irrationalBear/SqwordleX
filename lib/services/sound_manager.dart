import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager with WidgetsBindingObserver {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _effects = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();

  bool _muted = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool('sound_muted') ?? false;

    // Preload effects
    await _effects.setSource(AssetSource('sounds/button_press.mp3'));
    await _effects.setSource(AssetSource('sounds/keyboard_click.mp3'));
    await _effects.setSource(AssetSource('sounds/wrong_guess.mp3'));
    await _effects.setSource(AssetSource('sounds/correct_guess.mp3'));
    await _effects.setSource(AssetSource('sounds/win_fanfare.mp3'));
    await _effects.setSource(AssetSource('sounds/loss_sound.mp3'));
    await _effects.setSource(AssetSource('sounds/splash_fanfare.mp3'));
    await _effects.setSource(AssetSource('sounds/game_start.mp3'));

    _music.setReleaseMode(ReleaseMode.loop);
    await _music.setSource(AssetSource('sounds/ambient_loop.mp3'));

    if (!_muted) _music.play(AssetSource('sounds/ambient_loop.mp3'));

    // ← NEW: Start listening to app lifecycle globally
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _music.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (!_muted) _music.resume();
    }
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_muted', _muted);

    if (_muted) {
      _music.pause();
    } else {
      _music.resume();
    }
  }

  void playButton() => _play('sounds/button_press.mp3');
  void playKeyboard() => _play('sounds/keyboard_click.mp3');
  void playWrongGuess() => _play('sounds/wrong_guess.mp3');
  void playCorrectGuess() => _play('sounds/correct_guess.mp3');
  void playWin() => _play('sounds/win_fanfare.mp3');
  void playLoss() => _play('sounds/loss_sound.mp3');
  void playSplash() => _play('sounds/splash_fanfare.mp3');
  void playGameStart() => _play('sounds/game_start.mp3');

  void _play(String path) {
    if (_muted) return;
    _effects.play(AssetSource(path));
  }
}
