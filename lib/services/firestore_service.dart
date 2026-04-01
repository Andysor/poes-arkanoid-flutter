import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _scores = FirebaseFirestore.instance.collection('highscores');

  Future<void> submitScore({
    required String name,
    required int score,
    required int level,
  }) async {
    await _scores.add({
      'name': name,
      'score': score,
      'level': level,
      'timestamp': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 3));
  }

  Future<List<Map<String, dynamic>>> getTopScores({int limit = 10}) async {
    final snapshot = await _scores
        .orderBy('score', descending: true)
        .limit(limit)
        .get()
        .timeout(const Duration(seconds: 3));
    return snapshot.docs.map((d) => d.data()).toList();
  }
}
