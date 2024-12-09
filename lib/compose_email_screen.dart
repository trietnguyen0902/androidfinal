import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mail/draft_service.dart';
import 'package:mail/email_service.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComposeEmailScreen extends StatefulWidget {
  @override
  _ComposeEmailScreenState createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends State<ComposeEmailScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final EmailService _emailService = EmailService(username: 'your_email@gmail.com', password: 'your_password');
  final DraftService _draftService = DraftService();
  List<PlatformFile> _attachments = [];

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachments = result.files;
      });
    }
  }

  Future<void> _saveDraft() async {
    await _draftService.saveDraft('userId', {
      'from': 'your_email@gmail.com',
      'to': _recipientController.text,
      'cc': _ccController.text,
      'bcc': _bccController.text,
      'subject': _subjectController.text,
      'body': _bodyController.text,
      'attachments': _attachments.map((file) => file.name).toList(),
    });
  }

  @override
  void dispose() {
    if (_recipientController.text.isNotEmpty || _subjectController.text.isNotEmpty || _bodyController.text.isNotEmpty) {
      _saveDraft();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compose Email'),
        actions: [
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: _pickFiles,
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              await _emailService.sendEmail(
                recipient: _recipientController.text,
                subject: _subjectController.text,
                body: _bodyController.text,
                cc: _ccController.text.isNotEmpty ? _ccController.text.split(',') : null,
                bcc: _bccController.text.isNotEmpty ? _bccController.text.split(',') : null,
                attachments: _attachments,
              );

              // Save sent email information in Firestore
              await FirebaseFirestore.instance.collection('emails').add({
                'from': 'your_email@gmail.com',
                'to': _recipientController.text,
                'cc': _ccController.text,
                'bcc': _bccController.text,
                'subject': _subjectController.text,
                'body': _bodyController.text,
                'date': DateTime.now(),
                'isRead': true,
                'isStarred': false,
                'labels': [],
                'isTrashed': false,
                'isDraft': false,
              });

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _recipientController,
                decoration: InputDecoration(labelText: 'Recipient'),
              ),
              TextField(
                controller: _ccController,
                decoration: InputDecoration(labelText: 'CC'),
              ),
              TextField(
                controller: _bccController,
                decoration: InputDecoration(labelText: 'BCC'),
              ),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: 'Body'),
                maxLines: 8,
              ),
              SizedBox(height: 20),
              if (_attachments.isNotEmpty) ...[
                Text('Attachments:'),
                ..._attachments.map((file) => Text(file.name)).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
