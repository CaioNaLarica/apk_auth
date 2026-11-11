import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirestoreService()
    : notes = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notes');
  final CollectionReference<Map<String, dynamic>> notes;
  Future<void> create(String note) async {
    await notes.add({'note': note.trim(), 'timestamp': Timestamp.now()});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> read() =>
      notes.orderBy('timestamp', descending: true).snapshots();
  Future<void> update(String docID, String newNote) => notes.doc(docID).update({
    'note': newNote.trim(),
    'timestamp': Timestamp.now(),
  });
  Future<void> delete(String docID) => notes.doc(docID).delete();
}
