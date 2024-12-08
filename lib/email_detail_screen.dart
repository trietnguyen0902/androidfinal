import 'package:flutter/material.dart';
import 'email.dart';

class EmailDetailScreen extends StatelessWidget {
  final Email email;
  EmailDetailScreen({required this.email});

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
            Text(
              'From: ${email.sender}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${email.date.toString()}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              email.body,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.reply),
                  onPressed: () {
                    // Navigate to Compose Email Screen for replying
                  },
                ),
                IconButton(
                  icon: Icon(Icons.forward),
                  onPressed: () {
                    // Navigate to Compose Email Screen for forwarding
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Implement the delete (move to trash) functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
