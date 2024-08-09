import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truitrak2/constants/pallete.dart';
import 'package:truitrak2/screens/tuitions/service/client.dart';
import 'package:truitrak2/services/cloud/cloud_storage_exceptions.dart';
import 'package:truitrak2/widgets/login_field.dart';

class CreateNewClient extends StatefulWidget {
  const CreateNewClient({super.key});

  @override
  State<CreateNewClient> createState() => _CreateNewClientState();
}

class _CreateNewClientState extends State<CreateNewClient> {
  // ignore: unused_field
  CloudClient? _client;

  late final CloudClientStorage _clientService;
  late final TextEditingController _clientNameController;

  @override
  void initState() {
    _clientService = CloudClientStorage();
    _clientNameController = TextEditingController();
    super.initState();
  }

  Future<CloudClient> _createNewClient(String clienName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final newClient = await _clientService.createNewClient(
          name: clienName, ownerId: userId);
      _client = newClient;
      return newClient;
    } else {
      throw CouldNotCreateNoteException();
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Text('Create new Client here',
                style: TextStyle(
                  fontSize: 30,
                )),
            const SizedBox(height: 10),
            LoginField(
              hintText: 'Client Name',
              obs: false,
              textController: _clientNameController,
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Pallete.gradient1,
                    Pallete.gradient2,
                    Pallete.gradient3,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final name = _clientNameController.text;
                  _createNewClient(name);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(395, 55),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Create Client',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
