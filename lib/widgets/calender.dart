  import 'package:flutter/material.dart';
  import 'package:table_calendar/table_calendar.dart';
  import 'package:pillapp/database/sql_helper.dart';
  import 'package:intl/intl.dart';

  class CalendarWidget extends StatefulWidget {
    @override
    _CalendarWidgetState createState() => _CalendarWidgetState();
  }

  class _CalendarWidgetState extends State<CalendarWidget> {
    late CalendarFormat _calendarFormat;
    late DateTime _focusedDay;
    late DateTime _selectedDay;
    late List<Map<String, dynamic>> _appointments;
    late List<Map<String, dynamic>> _medicinesForDay;

    @override
    void initState() {
      super.initState();
      _calendarFormat = CalendarFormat.month;
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
      _appointments = [];
      _medicinesForDay = [];
      _fetchAppointments();
      _fetchMedicinesForDay(_selectedDay);
    }

    Future<void> _fetchAppointments() async {
      final appointments = await SQLHelper.getAppsForDay(_selectedDay.toString());
      setState(() {
        _appointments = appointments;
      });
    }

    Future<void> _fetchMedicinesForDay(DateTime selectedDay) async {
      // Get the day of the week (1 = Mon 7=Sun)
      int dayOfWeek = selectedDay.weekday;
      print('DAY OF WEEK $dayOfWeek');
      // Fetch meds for current day
      final medicines = await SQLHelper.getMedicinesForDay(dayOfWeek);

      setState(() {
        _medicinesForDay = medicines;
        print(_medicinesForDay);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              child: TableCalendar(
                firstDay: DateTime.utc(2021, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _fetchAppointments();
                    _fetchMedicinesForDay(selectedDay);
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                headerVisible: true,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black),
                  weekendStyle: TextStyle(color: Color.fromARGB(255, 117, 86, 255)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${DateFormat.yMMMMd('en_US').format(_selectedDay)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _appointments.length + _medicinesForDay.length,
                itemBuilder: (context, index) {
                  if (index < _appointments.length) {
                    final appointment = _appointments[index];
                    return _buildEventItem(appointment['title'], '${appointment['location']} ${appointment['dateTime']}', Icons.calendar_today, Color.fromARGB(255, 255, 255, 255));
                  } else {
                    final medicineIndex = index - _appointments.length;
                    final medicine = _medicinesForDay[medicineIndex];
                    return _buildEventItem(medicine['name'], '${medicine['reason']} ${medicine['time']}', Icons.medical_services, Color.fromARGB(255, 255, 255, 255));
                  }
                },
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildEventItem(String title, String detail, IconData iconData, Color iconColor) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.fromRGBO(86, 92, 143, 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              iconData,
              color: iconColor,
              size: 30,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 225, 220, 255),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
