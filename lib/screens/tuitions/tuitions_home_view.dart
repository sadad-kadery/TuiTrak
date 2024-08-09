import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:truitrak2/enums/menu_action.dart';
import 'package:truitrak2/screens/tuitions/client_main_screen.dart';
import 'package:truitrak2/screens/tuitions/sessions/session_main_view.dart';
import 'package:truitrak2/services/auth/bloc/auth_bloc.dart';
import 'package:truitrak2/services/auth/bloc/auth_event.dart';
import 'package:truitrak2/utilities/dialogs/logout_dialog.dart';

class TuitionHomeView extends StatefulWidget {
  const TuitionHomeView({super.key});

  @override
  State<TuitionHomeView> createState() => _TuitionHomeViewState();
}

class _TuitionHomeViewState extends State<TuitionHomeView> {
  late DateTime _focusedDay = DateTime.now();
  late DateTime _firstDay = DateTime(2023);
  late DateTime _lastDay = DateTime(2025);
  late DateTime _selectedDay;

  late Map<DateTime, List<Event>> _events;

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  _loadFirestoreEvents() async {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    _events = {};
    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: firstDay)
        .where('date', isLessThanOrEqualTo: lastDay)
        .withConverter(
            fromFirestore: Event.fromFirestore,
            toFirestore: (event, options) => event.toFirestore())
        .get();
    for (var doc in snap.docs) {
      final event = doc.data();
      final day =
          DateTime.utc(event.date.year, event.date.month, event.date.day);
      if (_events[day] == null) {
        _events[day] = [];
      }
      _events[day]!.add(event);
    }
    setState(() {});
  }

  List _getEventsForTheDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  void initState() {
    _focusedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    _selectedDay = DateTime.now();
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    _loadFirestoreEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEvent(
                firstDate: _firstDay,
                lastDate: _lastDay,
                selectedDate: _selectedDay,
              ),
            ),
          );
          if (result ?? false) {
            _loadFirestoreEvents();
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(

        title: const Text('Home'),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return const SessionView();
                  },
                ));
              },
              child: Text('Sessions')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return const ClientView();
                  },
                ));
              },
              child: Text('Clients')),
              PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
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
      body: ListView(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: _firstDay,
            lastDay: _lastDay,
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              _loadFirestoreEvents();
            },
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(day.toString()),
                );
              },
            ),
            eventLoader: _getEventsForTheDay,
            sixWeekMonthsEnforced: false,
          ),
          const SizedBox(height: 50),
         
          
          ..._getEventsForTheDay(_selectedDay).map(
            (event) => ListTile(
              title: Text(
                event.title,
              ),
              subtitle: Text(
                event.date.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  final String? description;
  final DateTime date;
  final String id;
  Event({
    required this.title,
    this.description,
    required this.date,
    required this.id,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return Event(
      date: data['date'].toDate(),
      title: data['title'],
      description: data['description'],
      id: snapshot.id,
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      "date": Timestamp.fromDate(date),
      "title": title,
      "description": description
    };
  }
}
           



























class AddEvent extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  const AddEvent(
      {Key? key,
      required this.firstDate,
      required this.lastDate,
      this.selectedDate})
      : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  late DateTime _selectedDate;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Event")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          InputDatePickerFormField(
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialDate: _selectedDate,
            onDateSubmitted: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          TextField(
            controller: _titleController,
            maxLines: 1,
            decoration: const InputDecoration(labelText: 'title'),
          ),
          TextField(
            controller: _descController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'description'),
          ),
          ElevatedButton(
            onPressed: () {
              _addEvent();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _addEvent() async {
    final title = _titleController.text;
    final description = _descController.text;
    if (title.isEmpty) {
      print('title cannot be empty');
      // you can use snackbar to display erro to the user
      return;
    }
    await FirebaseFirestore.instance.collection('events').add({
      "title": title,
      "description": description,
      "date": Timestamp.fromDate(_selectedDate),
    });
    if (mounted) {
      Navigator.pop<bool>(context, true);
    }
  }
}
