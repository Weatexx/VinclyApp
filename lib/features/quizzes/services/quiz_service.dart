import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../home/services/relationship_service.dart';
import '../../auth/services/auth_service.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  final RelationshipService _relService = RelationshipService();

  // Question keys for localization (maps to translation keys)
  final List<String> _questionKeys = [
    'quizzes.daily_questions.q1',
    'quizzes.daily_questions.q2',
    'quizzes.daily_questions.q3',
    'quizzes.daily_questions.q4',
    'quizzes.daily_questions.q5',
    'quizzes.daily_questions.q6',
    'quizzes.daily_questions.q7',
  ];

  String _getTodayDateStr() {
    return DateTime.now().toIso8601String().split('T').first; // e.g. 2026-03-27
  }

  // Get today's question in the current language
  String getTodayQuestion() {
    // Deterministic index based on days since epoch so it changes every day
    int days = DateTime.now().difference(DateTime(2025, 1, 1)).inDays;
    String questionKey = _questionKeys[days % _questionKeys.length];
    
    // Return the translated question
    return questionKey.tr();
  }

  String get getRelationshipId {
    // Hack: We need partnerUid to compute relationshipId.
    // Instead of querying partnerUid everywhere, ideally we store rel_id in the user's doc.
    return ""; // Will be computed in the function that uses partnerUid
  }

  String computeRelId(String partnerUid) {
    final currentUid = _auth.currentUserUid;
    if (currentUid == null) return "";
    List<String> ids = [currentUid, partnerUid];
    ids.sort();
    return "${ids[0]}_${ids[1]}";
  }

  // Stream today's answer document
  Stream<DocumentSnapshot> getTodayQuizStream(String partnerUid) {
    String relId = computeRelId(partnerUid);
    String date = _getTodayDateStr();
    return _firestore
        .collection('relationships')
        .doc(relId)
        .collection('daily_answers')
        .doc(date)
        .snapshots();
  }

  Future<void> submitAnswer(String partnerUid, String answer) async {
    String myUid = _auth.currentUserUid!;
    String relId = computeRelId(partnerUid);
    String date = _getTodayDateStr();

    var docRef = _firestore
        .collection('relationships')
        .doc(relId)
        .collection('daily_answers')
        .doc(date);

    await _firestore.runTransaction((transaction) async {
      var snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        // Create the document
        transaction.set(docRef, {
          'question': getTodayQuestion(),
          '${myUid}_answer': answer,
        });
      } else {
        // Update the document
        transaction.update(docRef, {'${myUid}_answer': answer});

        // Check if partner already answered, if so, increase streak!
        Map<String, dynamic> data = snapshot.data()!;
        if (data.containsKey('${partnerUid}_answer')) {
          // Both have answered now! This is the magical moment.
          // Let's increment streak in the parent relationship document.
          var relDoc = _firestore.collection('relationships').doc(relId);
          var relSnap = await transaction.get(relDoc);
          int currentStreak = relSnap.data()?['streak_count'] ?? 0;

          transaction.update(relDoc, {
            'streak_count': currentStreak + 1,
            'last_complete_quiz_date': date,
          });
        }
      }
    });
  }

  // Get past questions
  Future<List<Map<String, dynamic>>> getPastQuizzes(String partnerUid) async {
    String relId = computeRelId(partnerUid);
    var query = await _firestore
        .collection('relationships')
        .doc(relId)
        .collection('daily_answers')
        .get();

    return query.docs.map((doc) {
      var data = doc.data();
      data['date_id'] = doc.id;
      return data;
    }).toList();
  }
}
