import 'package:flutter/material.dart';
import 'package:truitrak2/screens/tuitions/service/client.dart';
import 'package:truitrak2/screens/tuitions/service/sessions.dart';

import 'package:truitrak2/screens/tuitions/update_client.dart';

import 'package:truitrak2/utilities/dialogs/delete_dialog.dart';

typedef SessionCallBack = void Function(CloudSession session);

class SessionListview extends StatelessWidget {
  final Iterable<CloudSession> sessions;
  final SessionCallBack onDeleteSession;
  final SessionCallBack onTap;

  const SessionListview({
    Key? key,
    required this.sessions,
    required this.onDeleteSession,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions.elementAt(index);
        //final String sessionName = session.clientName;
        final String sessionDate = session.date.toString();
        return ListTile(
          onTap: () {
           
          },
          title: Text(
            "dsd",
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteSession(session);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
