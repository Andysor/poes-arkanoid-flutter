import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'game/poes_arkanoid_game.dart';
import 'screens/name_input_screen.dart';
import 'screens/character_select_screen.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const PoesArkanoidApp());
}

class PoesArkanoidApp extends StatelessWidget {
  const PoesArkanoidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poes Arkanoid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const GameFlow(),
    );
  }
}

/// Manages the flow: Name Input -> Character Select -> Game
class GameFlow extends StatefulWidget {
  const GameFlow({super.key});

  @override
  State<GameFlow> createState() => _GameFlowState();
}

enum GameScreen { nameInput, characterSelect, playing }

class _GameFlowState extends State<GameFlow> {
  GameScreen _currentScreen = GameScreen.nameInput;
  String _playerName = '';
  String _selectedCharacter = 'RugbyBall';
  PoesArkanoidGame? _game;
  final _firestoreService = FirestoreService();

  void _onNameSubmitted(String name) {
    setState(() {
      _playerName = name;
      _currentScreen = GameScreen.characterSelect;
    });
  }

  void _onCharacterSelected(String character) {
    setState(() {
      _selectedCharacter = character;
      _game = PoesArkanoidGame(
        playerName: _playerName,
        selectedCharacter: _selectedCharacter,
      );
      _currentScreen = GameScreen.playing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_currentScreen) {
        GameScreen.nameInput => NameInputScreen(
          onSubmit: _onNameSubmitted,
        ),
        GameScreen.characterSelect => CharacterSelectScreen(
          playerName: _playerName,
          onCharacterSelected: _onCharacterSelected,
        ),
        GameScreen.playing => GameWidget(
          game: _game!,
          loadingBuilder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
          overlayBuilderMap: {
            'hud': (context, game) => _HudOverlay(game: _game!),
            'gameOver': (context, game) => _buildGameOverOverlay(context),
          },
          initialActiveOverlays: const ['hud'],
        ),
      },
    );
  }

  Widget _buildGameOverOverlay(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: ${_game?.score ?? 0}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              'Level: ${_game?.level ?? 1}',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 24),
            _GameOverActions(
              firestoreService: _firestoreService,
              playerName: _playerName,
              score: _game?.score ?? 0,
              level: _game?.level ?? 1,
              onPlayAgain: () {
                setState(() {
                  _game = null;
                  _currentScreen = GameScreen.nameInput;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverActions extends StatefulWidget {
  const _GameOverActions({
    required this.firestoreService,
    required this.playerName,
    required this.score,
    required this.level,
    required this.onPlayAgain,
  });

  final FirestoreService firestoreService;
  final String playerName;
  final int score;
  final int level;
  final VoidCallback onPlayAgain;

  @override
  State<_GameOverActions> createState() => _GameOverActionsState();
}

class _GameOverActionsState extends State<_GameOverActions> {
  List<Map<String, dynamic>>? _topScores;
  bool _submitting = true;

  @override
  void initState() {
    super.initState();
    _submitAndLoadScores();
  }

  Future<void> _submitAndLoadScores() async {
    try {
      final futures = <Future>[];
      if (widget.score > 0) {
        futures.add(widget.firestoreService.submitScore(
          name: widget.playerName,
          score: widget.score,
          level: widget.level,
        ));
      }
      futures.add(widget.firestoreService.getTopScores().then((scores) {
        if (mounted) _topScores = scores;
      }));

      await Future.wait(futures).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Network failure or timeout — show play again anyway
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_submitting)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: CircularProgressIndicator(),
          )
        else if (_topScores != null && _topScores!.isNotEmpty) ...[
          const Text(
            'HIGH SCORES',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            _topScores!.length,
            (i) {
              final s = _topScores![i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${i + 1}. ${s['name'] ?? '???'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '${s['score'] ?? 0}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton(
          onPressed: widget.onPlayAgain,
          child: const Text('Play Again'),
        ),
      ],
    );
  }
}

class _HudOverlay extends StatefulWidget {
  const _HudOverlay({required this.game});
  final PoesArkanoidGame game;

  @override
  State<_HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<_HudOverlay> {
  late final PoesArkanoidGame _game = widget.game;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Score: ${_game.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
            Text(
              'Level ${_game.level}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _game.lives.clamp(0, 99),
                (_) => const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.favorite, color: Colors.red, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
