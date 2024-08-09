import 'package:flutter/material.dart';
import 'package:truitrak2/constants/pallete.dart';
import 'package:truitrak2/screens/tuitions/service/client.dart';
import 'package:truitrak2/services/cloud/cloud_storage_exceptions.dart';
import 'package:truitrak2/utilities/generics/get_arguments.dart';
import 'package:truitrak2/widgets/login_field.dart';

class UpdateClient extends StatefulWidget {
  const UpdateClient({super.key});

  @override
  State<UpdateClient> createState() => _CreateNewClientState();
}

class _CreateNewClientState extends State<UpdateClient> {
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

  Future<CloudClient> createOrGetExistingClient(BuildContext context) async {
    final widgetNote = context.getArgument<CloudClient>();

    if (widgetNote != null) {
      _client = widgetNote;
      _clientNameController.text = widgetNote.name;
      return widgetNote;
    } else {
      throw CouldNotUpdateNoteException();
    }
  }

  void _updateClient(String documentId) async {
    final name = _clientNameController.text;
    await _clientService.updateClient(
      documentId: documentId,
      name: name,
    );
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Client'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text('Update Client here',
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
                _updateClient(documentId);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(395, 55),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Update',
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
    );
  }
}
