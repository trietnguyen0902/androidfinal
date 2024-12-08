import 'package:flutter/material.dart';
import 'email_model.dart';

class EmailDetails extends StatelessWidget {
  final Email email;

  EmailDetails({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(email.subject),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${email.from}'),
            Text('To: ${email.to}'),
            Text('Date: ${email.date}'),
            SizedBox(height: 20),
            Text(email.body),
          ],
        ),
      ),
    );
  }
}
