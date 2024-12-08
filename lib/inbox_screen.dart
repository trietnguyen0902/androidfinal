import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email.dart';
import 'email_detail_screen.dart';

class InboxScreen extends StatefulWidget {
  final String userId; // The userId will be passed from the login or profile screen
  InboxScreen({required this.userId});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {

  // Dynamically filter emails based on the userId
  Stream<List<Email>> _getEmailStream() {
    return FirebaseFirestore.instance
        .collection('emails')
        .where('recipient', isEqualTo: widget.userId) // Filter by current userId
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Email(
          id: doc.id,
          sender: doc['sender'],
          recipient: doc['recipient'],
          subject: doc['subject'],
          body: doc['body'],
          date: doc['date'].toDate(), // Make sure the date is properly converted
          attachments: List<String>.from(doc['attachments'] ?? []), // Handle null attachments
          labels: List<String>.from(doc['labels'] ?? []), // Handle null labels
          isRead: doc['isRead'] ?? false, // Default to false if not specified
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
      ),
      body: StreamBuilder<List<Email>>(
        stream: _getEmailStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No emails found.'));
          }

          final emails = snapshot.data!;

          return ListView.builder(
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index];
              return ListTile(
                leading: Icon(email.isRead ? Icons.mark_email_read : Icons.mark_email_unread),
                title: Text(email.subject),
                subtitle: Text('From: ${email.sender}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmailDetailScreen(email: email)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
