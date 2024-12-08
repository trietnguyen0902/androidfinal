import 'package:flutter/material.dart';
import 'email.dart';

class EmailListWidget extends StatelessWidget {
  final List<Email> emails;

  EmailListWidget({required this.emails});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: emails.length,
      itemBuilder: (context, index) {
        final email = emails[index];
        return ListTile(
          title: Text(email.subject),
          subtitle: Text(email.body),
          onTap: () {
            // Navigate to email detail screen
          },
        );
      },
    );
  }
}
