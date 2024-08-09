import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truitrak2/constants/pallete.dart';
import 'package:truitrak2/screens/tuitions/service/client.dart';
import 'package:truitrak2/screens/tuitions/service/sessions.dart';
import 'package:truitrak2/services/cloud/cloud_storage_exceptions.dart';
import 'package:truitrak2/widgets/login_field.dart';

class CreateNewSession extends StatefulWidget {
  const CreateNewSession({super.key});

  @override
  State<CreateNewSession> createState() => _CreateNewSessionState();
}

class _CreateNewSessionState extends State<CreateNewSession> {
  // ignore: unused_field
  CloudSession? _session;

  late final CloudSessionStorage _sessionservice;
  late final CloudClientStorage _clientService;
  late final TextEditingController _sessionDescriptionController;
  late final TextEditingController datePickerController;
  late final String clientName;

  List<String> _menuOptions = [];

  @override
  void initState() {
    _clientService = CloudClientStorage();
    _sessionservice = CloudSessionStorage();
    _sessionDescriptionController = TextEditingController();
    datePickerController = TextEditingController();
    fetchOptions().then((options) {
      setState(() {
        _menuOptions = options;
      });
    });
    super.initState();
  }

  // ignore: non_constant_identifier_names
  Future<CloudSession> _CreateNewSession(
    String sessionDescription,
    Timestamp date,
    //String clientId,
    String clientName,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final newSession = await _sessionservice.createNewSession(
        ownerId: userId,
        description: sessionDescription,
        date: date,
        //clientId: clientId,
        //clientName: clientName,
      );
      _session = newSession;
      return newSession;
    } else {
      throw CouldNotCreateNoteException();
    }
  }

  Future<List<String>> fetchOptions() async {
    List<String> options = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('clients').get();
    snapshot.docs.forEach((doc) {
      options.add(doc['name']);
    });
    return options;
  }

  @override
  void dispose() {
    _sessionDescriptionController.dispose();
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
            PopupMenuButton<String>(
              onSelected: (String result) {
                clientName = result;
                print(result);
              },
              itemBuilder: (BuildContext context) {
                return _menuOptions.map((String option) {
                  return PopupMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList();
              },
              child: const Text('Select Client'),
            ),
            TextField(
              controller: datePickerController,
              readOnly: true,
              decoration:
                  const InputDecoration(hintText: "Click here to select date"),
              onTap: () => onTapFunction(context: context),
            ),
            LoginField(
              hintText: 'Description',
              obs: false,
              textController: _sessionDescriptionController,
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
                  final description1 = _sessionDescriptionController.text;
                  final date = DateTime.parse(datePickerController.text);
                  final dateTS = Timestamp.fromDate(date);
                  final currentUser = FirebaseAuth.instance.currentUser;
                   _CreateNewSession(
                    description1,
                    dateTS,
                    //clientId,
                    clientName,
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(395, 55),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Create Session',
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

TextEditingController datePickerController = TextEditingController();
onTapFunction({required BuildContext context}) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    lastDate: DateTime.now(),
    firstDate: DateTime(2015),
    initialDate: DateTime.now(),
  );
  if (pickedDate == null) return;
  datePickerController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
}
