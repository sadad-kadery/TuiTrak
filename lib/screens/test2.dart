import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:truitrak2/constants/pallete.dart';
import 'package:truitrak2/enums/menu_action.dart';
import 'package:truitrak2/screens/tuitions/client_main_screen.dart';
import 'package:truitrak2/services/auth/bloc/auth_bloc.dart';
import 'package:truitrak2/services/auth/bloc/auth_event.dart';
import 'package:truitrak2/utilities/dialogs/logout_dialog.dart';
import 'package:truitrak2/utilities/notification.dart';

import 'dart:developer' as devtools show log;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _loadEvents();
    super.initState();
  }

  Future<void> _loadEvents() async {
    if (user == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('events')
        .get();

    Map<DateTime, List<Map<String, dynamic>>> events = {};
    for (var doc in snapshot.docs) {
      DateTime date = (doc['date'] as Timestamp).toDate();
      devtools.log(date.toString());
      String title = doc['eventTitle'];
      String description = doc['eventDescp'];
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add({
        'id': doc.id,
        'eventTitle': title,
        'eventDescp': description,
      });
    }

    setState(() {
      _events = events;
    });
    devtools.log(_events.toString());
  }

  void _addEvent(String title, String description) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime date = _selectedDay;
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .add({
      'date': date,
      'eventTitle': title,
      'eventDescp': description,
    });

    setState(() {
      if (_events[date] == null) {
        _events[date] = [];
      }
      _events[date]!.add({
        'id': docRef.id,
        'eventTitle': title,
        'eventDescp': description,
      });
    });
    LocalNotifications.showSimpleNotification(
      title: "TuiTrak",
      body: "Session has been added.",
      payload: "",
    );
  }

  void _updateEvent(String id, String title, String description) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime date = _selectedDay;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .doc(id)
        .update({
      'eventTitle': title,
      'eventDescp': description,
    });

    setState(() {
      List<Map<String, dynamic>> events = _events[date]!;
      int index = events.indexWhere((event) => event['id'] == id);
      if (index != -1) {
        events[index]['eventTitle'] = title;
        events[index]['eventDescp'] = description;
      }
    });
    LocalNotifications.showSimpleNotification(
      title: "TruiTrak",
      body: "Session has been updated.",
      payload: "",
    );
  }

  void _removeEvent(String id) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime date = _selectedDay;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .doc(id)
        .delete();

    setState(() {
      List<Map<String, dynamic>> events = _events[date]!;
      events.removeWhere((event) => event['id'] == id);
    });
    LocalNotifications.showSimpleNotification(
      title: "TruiTrak",
      body: "Session has been removed.",
      payload: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return const ClientView();
                  },
                ));
              },
              child: const Text(
                'Clients',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              )),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    // ignore: use_build_context_synchronously
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView(
              children: (_events[_selectedDay] ?? []).map((event) {
                return ListTile(
                  trailing: IconButton(
                    onPressed: () {
                      _removeEvent(event['id']);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  leading: const Icon(
                    Icons.event,
                    color: Colors.teal,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Session Title:   ${event['eventTitle']}'),
                  ),
                  subtitle: Text('Description:   ${event['eventDescp']}'),
                  onTap: () {
                    _showEditEventDialog(
                        event['id'], event['eventTitle'], event['eventDescp']);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_box),
          onPressed: () {
            _showAddEventDialog();
            devtools.log(_events.toString());
          }),
    );
  }

  void _showAddEventDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Enter Session title'),
            ),
            TextField(
              controller: descriptionController,
              decoration:
                  const InputDecoration(hintText: 'Enter Session description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              _addEvent(titleController.text, descriptionController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(String id, String title, String description) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController descriptionController =
        TextEditingController(text: description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Enter session title'),
            ),
            TextField(
              controller: descriptionController,
              decoration:
                  const InputDecoration(hintText: 'Enter session description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              _updateEvent(
                  id, titleController.text, descriptionController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
