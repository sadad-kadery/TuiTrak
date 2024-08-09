import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:truitrak2/constants/pallete.dart';
import 'dart:convert';

import 'package:truitrak2/enums/menu_action.dart';
import 'package:truitrak2/services/auth/bloc/auth_bloc.dart';
import 'package:truitrak2/services/auth/bloc/auth_event.dart';
import 'package:truitrak2/utilities/dialogs/logout_dialog.dart';

class TuitionHome extends StatefulWidget {
  const TuitionHome({super.key});

  @override
  State<TuitionHome> createState() => _TuitionHomeState();
}

class _TuitionHomeState extends State<TuitionHome> {
  CalendarFormat calenderFormat = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List> mySelectedEvents = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDay = _focusedDay;

    loadPreviousEvents();
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  loadPreviousEvents() {
    mySelectedEvents = {
      "2024-08-13": [
        {"eventDescp": "11", "eventTitle": "111"},
        {"eventDescp": "22", "eventTitle": "22"}
      ],
      "2022-08-30": [
        {"eventDescp": "22", "eventTitle": "22"}
      ],
      "2024-08-20": [
        {"eventTitle": "ss", "eventDescp": "ss"}
      ]
    };
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
               

                setState(() {
                  if (mySelectedEvents[
                          DateFormat('yyyy-MM-dd').format(_selectedDay!)] !=
                      null) {
                    mySelectedEvents[
                            DateFormat('yyyy-MM-dd').format(_selectedDay!)]
                        ?.add({
                      "eventTitle": titleController.text,
                      "eventDescp": descpController.text,
                    });
                  } else {
                    mySelectedEvents[
                        DateFormat('yyyy-MM-dd').format(_selectedDay!)] = [
                      {
                        "eventTitle": titleController.text,
                        "eventDescp": descpController.text,
                      }
                    ];
                  }
                });

                print(
                    "New Event for backend developer ${json.encode(mySelectedEvents)}");
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
      backgroundColor: Pallete.whiteColor,
      appBar: AppBar(
        actions: [
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hello, User',
          style: TextStyle(fontSize: 20, color: Pallete.whiteColor),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
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
                eventLoader: _listOfDayEvents,
                calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                        color: Pallete.whiteColor, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Pallete.gradient3, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(
                        color: Pallete.gradient2, shape: BoxShape.circle)),
                headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Pallete.whiteColor)),
              ),
            ),
          ),
          ..._listOfDayEvents(_selectedDay!).map(
            (myEvents) => ListTile(
              leading: const Icon(
                Icons.event,
                color: Colors.teal,
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Event Title:   ${myEvents['eventTitle']}'),
              ),
              subtitle: Text('Description:   ${myEvents['eventDescp']}'),
            ),
          ),
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
