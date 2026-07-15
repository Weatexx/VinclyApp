import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../home/services/relationship_service.dart';
import '../../auth/services/auth_service.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  final RelationshipService _relService = RelationshipService();

  
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
    return DateTime.now().toIso8601String().split('T').first; 
  }

  
  String getTodayQuestion() {
    
    int days = DateTime.now().difference(DateTime(2025, 1, 1)).inDays;
    String questionKey = _questionKeys[days % _questionKeys.length];
    
    
    return questionKey.tr();
  }

  String get getRelationshipId {
    
    
    return ""; 
  }

  String computeRelId(String partnerUid) {
    final currentUid = _auth.currentUserUid;
    if (currentUid == null) return "";
    List<String> ids = [currentUid, partnerUid];
    ids.sort();
    return "${ids[0]}_${ids[1]}";
  }

  
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
        
        transaction.set(docRef, {
          'question': getTodayQuestion(),
          '${myUid}_answer': answer,
        });
      } else {
        
        transaction.update(docRef, {'${myUid}_answer': answer});

        
        Map<String, dynamic> data = snapshot.data()!;
        if (data.containsKey('${partnerUid}_answer')) {
          
          
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
