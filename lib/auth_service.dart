import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _nicknameKey = 'saved_oyuncu_adi';
  static const String _faceKey = 'saved_yuz_index';
  static const String _accessoryKey = 'saved_aksesuar_index';
  static const String _colorKey = 'saved_renk_index';

  /// Firebase üzerinde anonim giriş yapar.
  ///
  /// Daha önce giriş yapılmışsa mevcut kullanıcıyı döndürür.
  Future<User?> signInAnonymously() async {
    try {
      if (_auth.currentUser != null) {
        return _auth.currentUser;
      }

      final UserCredential credential =
      await _auth.signInAnonymously();

      return credential.user;
    } catch (e) {
      print('Anonim giriş hatası: $e');
      return null;
    }
  }

  /// Oyuncunun adını ve avatar bilgilerini
  /// hem Firestore'a hem de cihaz hafızasına kaydeder.
  Future<bool> saveProfile({
    required String nickname,
    required int yuzIndex,
    required int aksesuarIndex,
    required int renkIndex,
  }) async {
    try {
      final String temizIsim = nickname.trim();

      if (temizIsim.isEmpty) {
        return false;
      }

      User? user = _auth.currentUser;

      user ??= await signInAnonymously();

      if (user == null) {
        return false;
      }

      final DocumentReference<Map<String, dynamic>> userDocument =
      _firestore.collection('users').doc(user.uid);

      final DocumentSnapshot<Map<String, dynamic>> existingDocument =
      await userDocument.get();

      if (existingDocument.exists) {
        await userDocument.set(
          {
            'uid': user.uid,
            'nickname': temizIsim,
            'yuzIndex': yuzIndex,
            'aksesuarIndex': aksesuarIndex,
            'renkIndex': renkIndex,
            'lastLogin': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        await userDocument.set(
          {
            'uid': user.uid,
            'nickname': temizIsim,
            'yuzIndex': yuzIndex,
            'aksesuarIndex': aksesuarIndex,
            'renkIndex': renkIndex,
            'score': 0,
            'wins': 0,
            'losses': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          },
        );
      }

      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        _nicknameKey,
        temizIsim,
      );

      await prefs.setInt(
        _faceKey,
        yuzIndex,
      );

      await prefs.setInt(
        _accessoryKey,
        aksesuarIndex,
      );

      await prefs.setInt(
        _colorKey,
        renkIndex,
      );

      return true;
    } catch (e) {
      print('Oyuncu profili kaydetme hatası: $e');
      return false;
    }
  }

  /// Eski kodlarla uyumluluk için yalnızca kullanıcı adını kaydeder.
  ///
  /// Yeni kodda mümkün olduğunca saveProfile kullan.
  Future<bool> saveNickname(String nickname) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    final int yuzIndex =
        prefs.getInt(_faceKey) ?? 0;

    final int aksesuarIndex =
        prefs.getInt(_accessoryKey) ?? 0;

    final int renkIndex =
        prefs.getInt(_colorKey) ?? 0;

    return saveProfile(
      nickname: nickname,
      yuzIndex: yuzIndex,
      aksesuarIndex: aksesuarIndex,
      renkIndex: renkIndex,
    );
  }

  /// Cihazda kayıtlı oyuncu adını getirir.
  Future<String?> getSavedNickname() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(_nicknameKey);
  }

  /// Cihazda kayıtlı oyuncu profilini getirir.
  Future<Map<String, dynamic>?> getSavedProfile() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final String? nickname =
      prefs.getString(_nicknameKey);

      if (nickname == null || nickname.trim().isEmpty) {
        return null;
      }

      return {
        'nickname': nickname.trim(),
        'yuzIndex': prefs.getInt(_faceKey) ?? 0,
        'aksesuarIndex': prefs.getInt(_accessoryKey) ?? 0,
        'renkIndex': prefs.getInt(_colorKey) ?? 0,
      };
    } catch (e) {
      print('Kayıtlı profil okuma hatası: $e');
      return null;
    }
  }

  /// Firestore'daki kullanıcı profilini getirir.
  Future<Map<String, dynamic>?> getCloudProfile() async {
    try {
      User? user = _auth.currentUser;

      user ??= await signInAnonymously();

      if (user == null) {
        return null;
      }

      final DocumentSnapshot<Map<String, dynamic>> document =
      await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!document.exists) {
        return null;
      }

      return document.data();
    } catch (e) {
      print('Bulut profili okuma hatası: $e');
      return null;
    }
  }

  /// Kullanıcının puanını Firestore üzerinde günceller.
  Future<bool> updateScore(int newScore) async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'score': newScore,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print('Puan güncelleme hatası: $e');
      return false;
    }
  }

  User? get currentUser => _auth.currentUser;
}