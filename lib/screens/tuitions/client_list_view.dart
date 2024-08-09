import 'package:flutter/material.dart';
import 'package:truitrak2/screens/tuitions/service/client.dart';
import 'package:truitrak2/screens/tuitions/update_client.dart';

import 'package:truitrak2/utilities/dialogs/delete_dialog.dart';

typedef ClientCallBack = void Function(CloudClient Client);

class ClientsListView extends StatelessWidget {
  final Iterable<CloudClient> clients;
  final ClientCallBack onDeleteClient;
  final ClientCallBack onTap;

  const ClientsListView({
    Key? key,
    required this.clients,
    required this.onDeleteClient,
     required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients.elementAt(index);
        return ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return const UpdateClient();
              },
              settings: RouteSettings(
                arguments: client.documentId
              ),
            ));
          },
          title: Text(
            client.name,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteClient(client);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
