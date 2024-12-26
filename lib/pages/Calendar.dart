import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewPage extends StatefulWidget {
  @override
  _CalendarViewPageState createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  Map<DateTime, String> _journalResults = {}; // Initialize as an empty map
  DateTime _focusedDay = DateTime.now();

  // Declare counters to keep track of wins, loses, and breakevens
  int totalWins = 0;
  int totalLoses = 0;
  int totalBreakeven = 0;

  @override
  void initState() {
    super.initState();
    _fetchJournalData(); // Fetch data from backend
  }

  // Fetch journal data from Firestore
  Future<void> _fetchJournalData() async {
    try {
      // Get the current user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not logged in.');
        return; // Exit if no user is logged in
      }

      final userId = user.uid; // Get user ID
      print('Fetching data for user: $userId');

      // Fetch journal entries for the logged-in user
      final snapshot = await FirebaseFirestore.instance
          .collection('confluences')
          .where('userId', isEqualTo: userId) // Filter by userId
          .get();

      // If no data found, log it
      if (snapshot.docs.isEmpty) {
        print('No journal entries found for this user.');
        return;
      }

      final results = <DateTime, String>{};
      int wins = 0, loses = 0, breakeven = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Check if the required fields are present
        if (data['entryDate'] == null || data['tradeResult'] == null) {
          print('Missing required fields in document: ${doc.id}');
          continue;
        }

        final entryDateString = data['entryDate'] as String;
        final tradeResult = data['tradeResult'] as String;

        // Log the tradeResult for debugging
        print("Fetched entry: $entryDateString, Result: $tradeResult");

        // Parse entryDate (string) into DateTime
        final dateParts = entryDateString.split('-');
        final entryDate = DateTime(
          int.parse(dateParts[0]), // Year
          int.parse(dateParts[1]), // Month
          int.parse(dateParts[2]), // Day
        );

        // Store the result for this date
        results[DateTime(entryDate.year, entryDate.month, entryDate.day)] =
            tradeResult;

        // Increment the appropriate counter based on tradeResult
        if (tradeResult == 'Win') {
          wins++;
        } else if (tradeResult == 'Lose') {
          loses++;
        } else if (tradeResult == 'Breakeven') {
          breakeven++;
        }
      }

      // Log the counters for debugging
      print('Wins: $wins, Loses: $loses, Breakeven: $breakeven');

      setState(() {
        _journalResults = results; // Update the journal results
        totalWins = wins; // Update the win count
        totalLoses = loses; // Update the lose count
        totalBreakeven = breakeven; // Update the breakeven count
        print("Journal results updated: $_journalResults");
      });
    } catch (error) {
      print('Error fetching journal data: $error');
    }
  }

  Widget _summaryCard({
    required Color color,
    required String label,
    required int value,
    required Color textColor,
  }) {
    return Container(
      width: 100,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 14.0, color: textColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C98E),
        elevation: 0,
        title:
            const Text('Calendar View', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              decoration: const BoxDecoration(color: Color(0xFF00C98E)),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              // Build custom marker for each day
              defaultBuilder: (context, day, focusedDay) {
                if (_journalResults.containsKey(day)) {
                  final result = _journalResults[day];
                  Color? bgColor;

                  if (result == 'Win') {
                    bgColor = Colors.green;
                  } else if (result == 'Lose') {
                    bgColor = Colors.red;
                  } else if (result == 'Breakeven') {
                    bgColor = Colors.lightBlue;
                  }

                  // Return a custom decorated container
                  return Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                return null; // No marker if no journal entry for this day
              },
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _summaryCard(
                    color: Colors.green.shade100,
                    label: 'WINS',
                    value: totalWins,
                    textColor: Colors.green,
                  ),
                  _summaryCard(
                    color: Colors.lightBlue.shade100,
                    label: 'BREAKEVEN',
                    value: totalBreakeven,
                    textColor: Colors.lightBlue,
                  ),
                  _summaryCard(
                    color: Colors.red.shade100,
                    label: 'LOSES',
                    value: totalLoses,
                    textColor: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 10), // Spacing between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _summaryCard(
                    color: Colors.grey.shade200,
                    label: 'Journal Entries',
                    value: _journalResults.length,
                    textColor: Colors.black,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
