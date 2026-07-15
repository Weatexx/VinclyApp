import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserUid => _auth.currentUser?.uid;

  // Sign Up
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
              'Kayıt işlemi zaman aşımına uğradı. (İnternet veya Sunucu hatası)',
            ),
          );

      // Create a document in Firestore
      if (userCredential.user != null) {
        String code = _generateVinclyCode();
        try {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'uid': userCredential.user!.uid,
                'first_name': firstName,
                'last_name': lastName,
                'email': email,
                'vincly_code': code,
                'partner_id': null,
                'created_at': FieldValue.serverTimestamp(),
              })
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw Exception(
                  'Veritabanı bağlantısı yok. (Kuralları kontrol edin)',
                ),
              );
        } catch (e) {
          // Rollback: Delete the user from Auth so it doesn't become orphaned and cause weird routing
          await userCredential.user!.delete().catchError((_) {});
          throw Exception('Profil oluşturulamadı: $e');
        }
      }
      return userCredential;
    } catch (e) {
      // Basic print for demo. Real app should use structured error handling
      print("Sign Up Error: $e");
      rethrow;
    }
  }

  // Log In
  Future<UserCredential?> logInWithEmail(String email, String password) async {
    try {
      return await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('Giriş işlemi zaman aşımına uğradı.'),
          );
    } catch (e) {
      print("Log In Error: $e");
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send Email Verification
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification().timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          throw Exception('Doğrulama e-postası gönderilemedi (Zaman Aşımı).'),
    );
  }

  // Reload current user to update emailVerified state
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload().timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          throw Exception('Kullanıcı durumu yenilenemedi (Zaman Aşımı).'),
    );
  }

  // Link Partner Output
  Future<bool> linkPartner(String code) async {
    String myUid = _auth.currentUser!.uid;

    // Find partner with that code
    var query = await _firestore
        .collection('users')
        .where('vincly_code', isEqualTo: code)
        .limit(1)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw Exception('Kod sorgulama işlemi zaman aşımına uğradı.'),
        );

    if (query.docs.isEmpty) {
      return false; // Code not found
    }

    String partnerUid = query.docs.first.id;
    if (partnerUid == myUid) {
      return false; // Can't link with yourself
    }

    // Update both documents
    WriteBatch batch = _firestore.batch();

    // Server timestamp for tracking relationship length
    final linkedAt = FieldValue.serverTimestamp();

    batch.update(_firestore.collection('users').doc(myUid), {
      'partner_id': partnerUid,
      'linked_at': linkedAt,
    });
    batch.update(_firestore.collection('users').doc(partnerUid), {
      'partner_id': myUid,
      'linked_at': linkedAt,
    });

    await batch.commit().timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          throw Exception('Eşleşme işlemi kaydedilemedi (Zaman Aşımı).'),
    );
    return true;
  }

  // Generate 6-char Alphanumeric Code
  String _generateVinclyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Stream user document for realtime updates
  Stream<DocumentSnapshot> getUserStream() {
    if (_auth.currentUser == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  // Stream partner document
  Stream<DocumentSnapshot> getPartnerStream(String partnerId) {
    if (partnerId.isEmpty) return const Stream.empty();
    return _firestore.collection('users').doc(partnerId).snapshots();
  }

  // Update current user's mood
  Future<void> updateMood(String emoji) async {
    if (_auth.currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({'mood': emoji})
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Mood güncellenemedi.'),
        );
  }

  // Update daily vibe score (1-10)
  Future<void> updateVibe(double vibe) async {
    if (_auth.currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({'vibe': vibe});
  }

  // Update user location for distance calculation
  Future<void> updateLocation(double lat, double lon) async {
    if (_auth.currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({'lat': lat, 'lon': lon});
  }

  // Complete Profile Setup
  Future<void> completeProfileSetup({
    required String displayName,
    required String language,
    String? assetAvatarPath,
    Uint8List? galleryImageBytes,
  }) async {
    String? finalPicUrl;

    // Determine which pic to save
    if (assetAvatarPath != null) {
      finalPicUrl =
          assetAvatarPath; // just store 'assets/avatars/avatar_fox.png'
    } else if (galleryImageBytes != null) {
      // Compress and upload via Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(
        'users/${_auth.currentUser!.uid}/profile.jpg',
      );

      // Add explicit content type for Safari/Web
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      var uploadTask = await ref
          .putData(galleryImageBytes, metadata)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('Fotoğraf yüklemesi zaman aşımına uğradı.'),
          );

      finalPicUrl = await uploadTask.ref.getDownloadURL();
    }

    // Save all to user document
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({
          'display_name': displayName,
          'language': language,
          'profile_pic_url': finalPicUrl,
          'setup_completed': true,
        })
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Profil kurulumu kaydedilemedi.'),
        );
  }

  Future<void> updateProfilePicture({
    Uint8List? galleryBytes,
    String? assetPath,
  }) async {
    String? finalPicUrl = assetPath;
    if (galleryBytes != null) {
      final ref = FirebaseStorage.instance.ref().child(
        'users/${_auth.currentUser!.uid}/profile.jpg',
      );
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      var uploadTask = await ref
          .putData(galleryBytes, metadata)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('Fotoğraf yüklemesi zaman aşımına uğradı.'),
          );
      finalPicUrl = await uploadTask.ref.getDownloadURL();
    }
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'profile_pic_url': finalPicUrl,
    });
  }

  // Unlink Partner
  Future<void> unlinkPartner() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return;

    final partnerId = doc.data()?['partner_id'];
    WriteBatch batch = _firestore.batch();

    batch.update(_firestore.collection('users').doc(user.uid), {
      'partner_id': null,
    });
    if (partnerId != null) {
      batch.update(_firestore.collection('users').doc(partnerId), {
        'partner_id': null,
      });
    }

    await batch.commit();
  }

  // Delete Account completely
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // First, safely unlink partner to prevent them from being glued to a ghost account
    await unlinkPartner();

    // Delete Firestore document
    await _firestore.collection('users').doc(user.uid).delete();

    // Delete Auth Authentication Record
    await user.delete();
  }
}
