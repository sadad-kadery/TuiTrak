import 'package:flutter/material.dart';
import 'package:truitrak2/screens/tuitions/client_list_view.dart';
import 'package:truitrak2/screens/tuitions/create_new_client.dart';
import 'package:truitrak2/screens/tuitions/service/client.dart';
import 'package:truitrak2/screens/tuitions/update_client.dart';
import 'package:truitrak2/services/auth/auth_services.dart';





class ClientView extends StatefulWidget {
  const ClientView({Key? key}) : super(key: key);

  @override
  _ClientViewState createState() => _ClientViewState();
}

class _ClientViewState extends State<ClientView> {
  late final CloudClientStorage _clientService;
  String get userId => AuthService.firebase().currentUser!.id;
  @override
  void initState() {
    _clientService = CloudClientStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Clients',style: TextStyle(
          color: Colors.black87
        ),),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const CreateNewClient();
                },
              ));
            },
            icon: const Icon(Icons.add,
            size: 30),
          ),
          
        ],
      ),
      body: StreamBuilder(
        stream: _clientService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudClient>;
                return ClientsListView(
                  clients: allNotes,
                  onDeleteClient: (client) async {
                    await _clientService.deleteClient(documentId: client.documentId);
                  },
                  onTap: (client) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return const UpdateClient();
                    },));
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
