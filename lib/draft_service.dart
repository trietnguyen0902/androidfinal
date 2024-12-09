import 'package:cloud_firestore/cloud_firestore.dart';

class DraftService {
  final CollectionReference draftCollection = FirebaseFirestore.instance.collection('drafts');

  Future<void> saveDraft(String userId, Map<String, dynamic> draftData) async {
    await draftCollection.doc(userId).set(draftData);
  }

  Future<Map<String, dynamic>?> getDraft(String userId) async {
    DocumentSnapshot doc = await draftCollection.doc(userId).get();
    return doc.exists ? doc.data() as Map<String, dynamic>? : null;
  }

  Future<void> deleteDraft(String userId) async {
    await draftCollection.doc(userId).delete();
  }
}
