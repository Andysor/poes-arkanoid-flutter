import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/poes_arkanoid_game.dart';
import 'screens/name_input_screen.dart';
import 'screens/character_select_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode on mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Hide system UI for immersive gameplay
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

  void _onGameOver() {
    setState(() {
      _game = null;
      _currentScreen = GameScreen.nameInput;
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
          overlayBuilderMap: {
            'gameOver': (context, game) => _buildGameOverOverlay(context),
          },
        ),
      },
    );
  }

  Widget _buildGameOverOverlay(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onGameOver,
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
