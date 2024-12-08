import 'package:flutter/material.dart';
import 'package:mail/email_detail_screen.dart';
import 'email_service.dart';
import 'email.dart';

class EmailsByLabelScreen extends StatelessWidget {
  final String label;
  EmailsByLabelScreen({required this.label});

  final EmailService _emailService = EmailService();

  Stream<List<Email>> _emailStream(String label) {
    return _emailService.getEmailsByLabel(label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emails - $label'),
      ),
      body: StreamBuilder<List<Email>>(
        stream: _emailStream(label),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No emails with this label.'));
          }

          final emails = snapshot.data!;

          return ListView.builder(
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index];
              return ListTile(
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
