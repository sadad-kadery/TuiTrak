import 'package:flutter/material.dart';
import 'package:truitrak2/screens/tuitions/client_list_view.dart';
import 'package:truitrak2/screens/tuitions/create_new_client.dart';
import 'package:truitrak2/screens/tuitions/service/client.dart';
import 'package:truitrak2/screens/tuitions/service/sessions.dart';
import 'package:truitrak2/screens/tuitions/sessions/sessions_list_view.dart';

import 'package:truitrak2/screens/tuitions/update_client.dart';
import 'package:truitrak2/services/auth/auth_services.dart';





class SessionView extends StatefulWidget {
  const SessionView({Key? key}) : super(key: key);

  @override
  _SessionViewState createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  late final CloudSessionStorage _sessionService;
  String get userId => AuthService.firebase().currentUser!.id;


  late DateTime _selectedDay;


  @override
  void initState() {
    _sessionService = CloudSessionStorage();
    _selectedDay = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Sessions'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const CreateNewClient();
                },
              ));
            },
            icon: const Icon(Icons.add),
          ),
          
        ],
      ),
      body: StreamBuilder(
        stream: _sessionService.allSessions(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allSessions = snapshot.data as Iterable<CloudSession>;
                return SessionListview(
                  sessions: allSessions,
                  onDeleteSession: (client) async {
                    await _sessionService.deleteSession(documentId: client.documentId);
                  },
                  onTap: (client) {
                    
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
