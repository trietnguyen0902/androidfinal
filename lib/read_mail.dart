import 'package:flutter/material.dart';

class ReadMail extends StatelessWidget {
  final String mailID;
  final String sendTo;
  final String carbonCopy;
  final String blindCopy;
  final String sender;
  final String title;
  final String content;
  final bool favorited;

  ReadMail({
    required this.mailID,
    required this.sendTo,
    required this.carbonCopy,
    required this.blindCopy,
    required this.sender,
    required this.title,
    required this.content,
    required this.favorited,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: $sender', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('To: $sendTo'),
              if (carbonCopy.isNotEmpty) Text('CC: $carbonCopy'),
              if (blindCopy.isNotEmpty) Text('BCC: $blindCopy'),
              SizedBox(height: 16),
              Text('Subject: $title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(content),
            ],
          ),
        ),
      ),
    );
  }
}
