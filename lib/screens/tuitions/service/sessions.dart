import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truitrak2/services/cloud/cloud_storage_exceptions.dart';

class CloudSession {
  final String documentId;
  final String ownerUserId;
  final String description;
  final Timestamp date;

  const CloudSession({
    required this.date,
    required this.documentId,
    required this.ownerUserId,
    required this.description,
  });
  CloudSession.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        date = snapshot.data()['date'] as Timestamp,
        ownerUserId = snapshot.data()['user_id'],
        description = snapshot.data()['description'] as String;
  //clientId = snapshot.data()['client_id'] as String,
  //clientName = snapshot.data()['client_name'] as String;
}

class CloudSessionStorage {
  final sessions = FirebaseFirestore.instance.collection('sessions');

  static final CloudSessionStorage _shared =
      CloudSessionStorage._sharedInstance();
  CloudSessionStorage._sharedInstance();
  factory CloudSessionStorage() => _shared;

  Future<CloudSession> createNewSession({
    required String ownerId,
    required String description,
    required Timestamp date,
    //required String clientId,
    
  }) async {
    final document = await sessions.add({
      'user_id': ownerId,
      'description': description,
      'date': date,
    });
    final fetchedSession = await document.get();
    return CloudSession(
      documentId: fetchedSession.id,
      ownerUserId: ownerId,
      description: description,
      date: date,
      // clientId: clientId,
      //clientName: clientName,
    );
  }

  Future<void> deleteSession({required String documentId}) async {
    try {
      await sessions.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updatesessions({
    required String documentId,
    required String description,
    required Timestamp date,
  }) async {
    try {
      await sessions.doc(documentId).update({'description': description});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudSession>> allSessions({required String ownerUserId}) =>
      sessions.snapshots().map((event) => event.docs
          .map((doc) => CloudSession.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));
}
