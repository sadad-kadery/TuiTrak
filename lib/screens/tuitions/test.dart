import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:truitrak2/constants/pallete.dart';
import 'package:truitrak2/enums/menu_action.dart';
import 'package:truitrak2/services/auth/bloc/auth_bloc.dart';
import 'package:truitrak2/services/auth/bloc/auth_event.dart';

import '../../utilities/dialogs/logout_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat calenderFormat = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, Event> myEventsMap = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDay = _focusedDay;

    loadPreviousEvents();
  }

  void removeEvent(Map<String, List> map, String key, String event) {
    // Check if the map contains the key
    if (map.containsKey(key)) {
      // Retrieve the list for the given key
      List eventsList = map[key]!;

      // Remove the element from the list
      eventsList.remove(event);

      // Update the map with the modified list
      map[key] = eventsList;
    }
  }

  // List _listOfDayEvents(DateTime dateTime) {
  //   if (myEventsMap[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
  //     return myEventsMap[DateFormat('yyyy-MM-dd').format(dateTime)]!;
  //   } else {
  //     return [];
  //   }
  // }

  loadPreviousEvents() {
    myEventsMap = {};
  }

  _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Tuition',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: descpController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Add Event'),
            onPressed: () {
              if (titleController.text.isEmpty &&
                  descpController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Required title and description'),
                    duration: Duration(seconds: 2),
                  ),
                );
                //Navigator.pop(context);
                return;
              } else {
                print(titleController.text);
                print(descpController.text);

                setState(() {
                  if (myEventsMap[
                          DateFormat('yyyy-MM-dd').format(_selectedDay!)] !=
                      null) {
                    myEventsMap[
                            DateFormat('yyyy-MM-dd').format(_selectedDay!)] =
                        Event(
                            name: titleController.text,
                            description: descpController.text);
                  } else {
                    myEventsMap[
                            DateFormat('yyyy-MM-dd').format(_selectedDay!)] =
                        Event(
                            name: titleController.text,
                            description: descpController.text);
                  }
                });

                print(
                    "New Event for backend developer ${json.encode(myEventsMap)}");
                titleController.clear();
                descpController.clear();
                Navigator.pop(context);
                return;
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 1, color: Pallete.gradient2),
              ),
              child: TableCalendar(
                sixWeekMonthsEnforced: true,
                focusedDay: _focusedDay,
                firstDay: DateTime(2022),
                lastDay: DateTime(2025),
                calendarFormat: calenderFormat,
                startingDayOfWeek: StartingDayOfWeek.saturday,
                rowHeight: 40,
                daysOfWeekHeight: 40,
                selectedDayPredicate: (day) {
                  // Use `selectedDayPredicate` to determine which day is currently selected.
                  // If this returns true, then `day` will be marked as selected.
                  // Using `isSameDay` is recommended to disregard
                  // the time-part of compared DateTime objects.
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    // Call `setState()` when updating the selected day
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                //eventLoader: //_listOfDayEvents,
                calendarStyle: const CalendarStyle(
                    markerDecoration: BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Pallete.gradient3, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(
                        color: Pallete.gradient2, shape: BoxShape.circle)),
                headerStyle: const HeaderStyle(
                    titleTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Pallete.gradient3)),
              ),
            ),
          ),
          // ..._listOfDayEvents(_selectedDay!).map(
          //   (myEvents) => ListTile(
          //     trailing: IconButton(
          //       onPressed: () {
                  
          //       },
          //       icon: const Icon(Icons.delete),
          //     ),
          //     leading: const Icon(
          //       Icons.event,
          //       color: Colors.teal,
          //     ),
          //     title: Padding(
          //       padding: const EdgeInsets.only(bottom: 8.0),
          //       child: Text('Event Title:   ${myEvents['eventTitle']}'),
          //     ),
          //     subtitle: Text('Description:   ${myEvents['eventDescp']}'),
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddEventDialog();
        },
        label: const Text('Add Tuition'),
      ),
    );
  }
}

class Event {
  final String name;
  final String description;

  Event({required this.name, required this.description});
}
