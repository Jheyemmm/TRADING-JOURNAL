import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditEntryPage extends StatefulWidget {
  final String documentId;
  final String pairsIndex;
  final String entryDate;
  final String tradeResult;
  final String confluences;
  final String recap;
  final String session;
  final String trend;

  const EditEntryPage({
    Key? key,
    required this.documentId,
    required this.pairsIndex,
    required this.entryDate,
    required this.tradeResult,
    required this.confluences,
    required this.recap,
    required this.session,
    required this.trend,
  }) : super(key: key);

  @override
  _EditEntryPageState createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  final TextEditingController _entryDateController = TextEditingController();
  final TextEditingController _pairsIndexController = TextEditingController();
  final TextEditingController _confluencesController = TextEditingController();
  final TextEditingController _recapController = TextEditingController();

  String? _selectedTradeResult;
  String? _selectedSession;
  String? _selectedTrend;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the existing data
    _entryDateController.text = widget.entryDate;
    _pairsIndexController.text = widget.pairsIndex;
    _confluencesController.text = widget.confluences;
    _recapController.text = widget.recap;
    _selectedTradeResult = widget.tradeResult;
    _selectedSession = widget.session;
    _selectedTrend = widget.trend;
  }

  // Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_entryDateController.text),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _entryDateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Firestore Update Method
  Future<void> _updateToFirestore() async {
    if (_entryDateController.text.isEmpty ||
        _pairsIndexController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('journalEntries')
          .doc(widget.documentId)
          .update({
        'entryDate': _entryDateController.text,
        'tradeResult': _selectedTradeResult ?? 'Not selected',
        'pairsIndex': _pairsIndexController.text,
        'session': _selectedSession ?? 'Not selected',
        'confluences': _confluencesController.text,
        'trend': _selectedTrend ?? 'Not selected',
        'recap': _recapController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating entry: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Journal Entry'),
        backgroundColor: const Color(0xFF00C98E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Entry Date
            TextField(
              controller: _entryDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Entry Date *',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),

            // Trade Result Dropdown
            DropdownButtonFormField<String>(
              value: _selectedTradeResult,
              decoration: const InputDecoration(
                labelText: 'Trade Result',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _selectedTradeResult = value);
              },
              items: const [
                DropdownMenuItem(value: 'Win', child: Text('Win')),
                DropdownMenuItem(value: 'Breakeven', child: Text('Breakeven')),
                DropdownMenuItem(value: 'Lose', child: Text('Lose')),
              ],
            ),
            const SizedBox(height: 16),

            // Pairs/Index field
            TextField(
              controller: _pairsIndexController,
              decoration: const InputDecoration(
                labelText: 'Pairs/Index *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Session Dropdown
            DropdownButtonFormField<String>(
              value: _selectedSession,
              decoration: const InputDecoration(
                labelText: 'Session',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _selectedSession = value);
              },
              items: const [
                DropdownMenuItem(
                    value: 'Asian Session', child: Text('Asian Session')),
                DropdownMenuItem(
                    value: 'London Session', child: Text('London Session')),
                DropdownMenuItem(
                    value: 'New York Morning Session',
                    child: Text('New York Morning Session')),
                DropdownMenuItem(
                    value: 'New York Afternoon Session',
                    child: Text('New York Afternoon Session')),
              ],
            ),
            const SizedBox(height: 16),

            // Confluences Field
            TextField(
              controller: _confluencesController,
              decoration: const InputDecoration(
                labelText: 'Confluences',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Trend Dropdown
            DropdownButtonFormField<String>(
              value: _selectedTrend,
              decoration: const InputDecoration(
                labelText: 'Trend',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _selectedTrend = value);
              },
              items: const [
                DropdownMenuItem(value: 'Uptrend', child: Text('Bullish')),
                DropdownMenuItem(value: 'Downtrend', child: Text('Bearish')),
              ],
            ),
            const SizedBox(height: 16),

            // Recap Field
            TextField(
              controller: _recapController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Recap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _updateToFirestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00C98E),
                side: const BorderSide(color: Color(0xFF00C98E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF00C98E))
                  : const Text(
                      'Update Entry',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
