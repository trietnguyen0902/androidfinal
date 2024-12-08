import 'package:flutter/material.dart';
import 'email_service.dart';
import 'email.dart';

class LabelManagementScreen extends StatefulWidget {
  final Email email;
  LabelManagementScreen({required this.email});

  @override
  _LabelManagementScreenState createState() => _LabelManagementScreenState();
}

class _LabelManagementScreenState extends State<LabelManagementScreen> {
  final EmailService _emailService = EmailService();
  List<String> _availableLabels = ['Work', 'Personal', 'Urgent', 'Important']; // Example labels
  List<String> _currentLabels = [];

  @override
  void initState() {
    super.initState();
    _currentLabels = List.from(widget.email.labels); // Load current labels
  }

  void _toggleLabel(String label) {
    setState(() {
      if (_currentLabels.contains(label)) {
        _currentLabels.remove(label);
      } else {
        _currentLabels.add(label);
      }
    });
  }

  void _saveLabels() async {
    await _emailService.updateEmailLabels(widget.email.id, _currentLabels);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Labels')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select labels for this email:'),
            SizedBox(height: 10),
            Wrap(
              children: _availableLabels.map((label) {
                return ChoiceChip(
                  label: Text(label),
                  selected: _currentLabels.contains(label),
                  onSelected: (selected) => _toggleLabel(label),
                );
              }).toList(),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _saveLabels,
              child: Text('Save Labels'),
            ),
          ],
        ),
      ),
    );
  }
}
