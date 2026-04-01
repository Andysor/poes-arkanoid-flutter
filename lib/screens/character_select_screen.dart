import 'package:flutter/material.dart';

import '../game/config/asset_paths.dart';

/// Character selection screen.
///
/// Shows the 5 SA-themed characters for the player to pick.
/// Precaches images on first build to avoid visible loading delay.
class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({
    super.key,
    required this.playerName,
    required this.onCharacterSelected,
  });

  final String playerName;
  final void Function(String characterKey) onCharacterSelected;

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  static const _characterLabels = <String, String>{
    'SAFlag': 'SA Flag',
    'Springbok': 'Springbok',
    'Voortrekker': 'Voortrekker',
    'Braai': 'Braai',
    'RugbyBall': 'Rugby Ball',
  };

  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      for (final path in AssetPaths.characters.values) {
        precacheImage(AssetImage('assets/images/$path'), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome, ${widget.playerName}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your character',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: AssetPaths.characters.entries.map((entry) {
                return _CharacterOption(
                  assetPath: 'assets/images/${entry.value}',
                  label: _characterLabels[entry.key] ?? entry.key,
                  onTap: () => widget.onCharacterSelected(entry.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterOption extends StatelessWidget {
  const _CharacterOption({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(assetPath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
