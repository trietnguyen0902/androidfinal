import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfile> getUserProfile(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      return UserProfile(
        id: snapshot.id,
        name: snapshot['name'],
        email: snapshot['email'],
        profileImageUrl: snapshot['profileImageUrl'],
      );
    } catch (e) {
      print("Error fetching profile: $e");
      rethrow;
    }
  }

  Future<void> updateProfile(String userId, UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': profile.name,
        'email': profile.email,
        'profileImageUrl': profile.profileImageUrl,
      });
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}
