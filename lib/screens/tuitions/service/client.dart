

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truitrak2/services/cloud/cloud_storage_exceptions.dart';

class CloudClient {
  final String documentId;
  final String ownerUserId;
  final String name;
  const CloudClient({
    required this.documentId,
    required this.ownerUserId,
    required this.name,

    
  });
   CloudClient.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()['user_id'],
        name = snapshot.data()['name'] as String;
}

class CloudClientStorage {
  final clients = FirebaseFirestore.instance.collection('clients');

   static final CloudClientStorage _shared =
      CloudClientStorage._sharedInstance();
  CloudClientStorage._sharedInstance();
  factory CloudClientStorage() => _shared;

  Future<CloudClient> createNewClient(
      {required String ownerId, required String name}) async {
    final document = await clients.add({
      'user_id': ownerId,
      'name': name,
    });
    final fetchedNote = await document.get();
    return CloudClient(
      documentId: fetchedNote.id,
      ownerUserId: ownerId,
      name: name,
    );
  }



  Future<void> deleteClient({required String documentId}) async {
    try {
      await clients.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }


  Future<void> updateClient({
    required String documentId,
    required String name,
  }) async {
    try {
      await clients.doc(documentId).update({'name': name});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudClient>> allNotes({required String ownerUserId}) =>
      clients.snapshots().map((event) => event.docs
          .map((doc) => CloudClient.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));



}
