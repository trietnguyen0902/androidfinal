import 'package:cloud_firestore/cloud_firestore.dart';

class LabelService {
  final CollectionReference labelCollection = FirebaseFirestore.instance.collection('labels');

  Future<void> createLabel(String labelName) async {
    await labelCollection.add({
      'name': labelName,
    });
  }

  Future<void> deleteLabel(String labelId) async {
    await labelCollection.doc(labelId).delete();
  }

  Future<void> updateLabel(String labelId, String newName) async {
    await labelCollection.doc(labelId).update({
      'name': newName,
    });
  }
}
