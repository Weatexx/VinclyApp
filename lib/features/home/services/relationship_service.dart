import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RelationshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  
  String _getRelationshipId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return "${ids[0]}_${ids[1]}";
  }

  
  Stream<DocumentSnapshot> getRelationshipStream(String partnerUid) {
    if (currentUid == null) return const Stream.empty();
    String relId = _getRelationshipId(currentUid!, partnerUid);
    return _firestore.collection('relationships').doc(relId).snapshots();
  }

  
  Future<void> initializeRelationship(String partnerUid) async {
    if (currentUid == null) return;
    String relId = _getRelationshipId(currentUid!, partnerUid);

    var docSnap = await _firestore.collection('relationships').doc(relId).get();
    if (!docSnap.exists) {
      await _firestore.collection('relationships').doc(relId).set({
        'user1_id': currentUid,
        'user2_id': partnerUid,
        'streak_count': 0,
        'last_complete_quiz_date': null,
      });
    }
  }

  
  Future<int?> checkStreakStatus(String partnerUid) async {
    if (currentUid == null) return null;
    String relId = _getRelationshipId(currentUid!, partnerUid);

    var docSnap = await _firestore.collection('relationships').doc(relId).get();
    if (!docSnap.exists) return null;

    var data = docSnap.data() as Map<String, dynamic>;
    int currentStreak = data['streak_count'] ?? 0;
    String? lastDateStr = data['last_complete_quiz_date'];

    if (currentStreak > 0 && lastDateStr != null) {
      
      DateTime lastDate = DateTime.parse(lastDateStr);
      DateTime now = DateTime.now();

      
      DateTime justDateLast = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );
      DateTime justDateNow = DateTime(now.year, now.month, now.day);

      int daysDiff = justDateNow.difference(justDateLast).inDays;

      
      if (daysDiff > 1) {
        await breakStreak(partnerUid);
        return currentStreak; 
      }
    }
    return null;
  }

  Future<void> breakStreak(String partnerUid) async {
    if (currentUid == null) return;
    String relId = _getRelationshipId(currentUid!, partnerUid);

    await _firestore.collection('relationships').doc(relId).update({
      'streak_count': 0,
    });
  }

  Future<void> useFreeRevive(String partnerUid, int previousStreak) async {
    if (currentUid == null) return;
    String relId = _getRelationshipId(currentUid!, partnerUid);

    
    var userDoc = _firestore.collection('users').doc(currentUid!);
    await _firestore.runTransaction((transaction) async {
      var snapshot = await transaction.get(userDoc);
      
      
      int revives = snapshot.data()?['free_revives_left'] ?? 2;
      if (revives > 0) {
        transaction.update(userDoc, {'free_revives_left': revives - 1});
        
        transaction.update(_firestore.collection('relationships').doc(relId), {
          'streak_count': previousStreak, 
          
          'last_complete_quiz_date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String()
              .split('T')
              .first,
        });
      }
    });
  }
}
