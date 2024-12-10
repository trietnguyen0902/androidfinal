import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mail/email_model.dart';
import 'email_service.dart'; 

class ComposeEmailScreen extends StatefulWidget {
  final Email? draft;

  const ComposeEmailScreen({super.key, this.draft});

  @override
  _ComposeEmailScreenState createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends State<ComposeEmailScreen> with WidgetsBindingObserver {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  List<PlatformFile> _attachments = [];
  bool _isDraftSaved = false;
  bool _isNewDraft = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.draft != null) {
      _loadDraft(widget.draft!);
      _isNewDraft = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_isDraftSaved) {
      _saveDraft();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (!_isDraftSaved) {
        _saveDraft();
      }
    }
  }

  void _loadDraft(Email draft) {
    _recipientController.text = draft.to;
    _subjectController.text = draft.subject;
    _bodyController.text = draft.body;
  }

  bool _hasContent() {
    return _recipientController.text.isNotEmpty ||
        _ccController.text.isNotEmpty ||
        _bccController.text.isNotEmpty ||
        _subjectController.text.isNotEmpty ||
        _bodyController.text.isNotEmpty ||
        _attachments.isNotEmpty;
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachments = result.files;
      });
    }
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  Future<void> _saveDraft() async {
    if (!_hasContent()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (_isNewDraft) {
       
        await FirebaseFirestore.instance.collection('emails').add({
          'from': user.email,
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
          'isDraft': true,
        });
      } else {
       
        await FirebaseFirestore.instance.collection('emails').doc(widget.draft!.id).update({
          'to': _recipientController.text,
          'cc': _ccController.text,
          'bcc': _bccController.text,
          'subject': _subjectController.text,
          'body': _bodyController.text,
          'date': DateTime.now(),
        });
      }
      setState(() {
        _isDraftSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved')),
      );
    }
  }

  Future<void> _sendEmail() async {
    if (!_isValidPhoneNumber(_recipientController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    await EmailService(username: 'your_email@gmail.com', password: 'your_password').sendEmail(
      recipient: _recipientController.text,
      subject: _subjectController.text,
      body: _bodyController.text,
      cc: _ccController.text.isNotEmpty ? _ccController.text.split(',') : null,
      bcc: _bccController.text.isNotEmpty ? _bccController.text.split(',') : null,
      attachments: _attachments,
    );

    if (_isNewDraft) {
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
    } else {
      await FirebaseFirestore.instance.collection('emails').doc(widget.draft!.id).update({
        'to': _recipientController.text,
        'cc': _ccController.text,
        'bcc': _bccController.text,
        'subject': _subjectController.text,
        'body': _bodyController.text,
        'date': DateTime.now(),
        'isDraft': false,
      });
    }

    Navigator.pop(context, true); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickFiles,
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendEmail,
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
                decoration: const InputDecoration(labelText: 'Recipient Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _ccController,
                decoration: const InputDecoration(labelText: 'CC'),
              ),
              TextField(
                controller: _bccController,
                decoration: const InputDecoration(labelText: 'BCC'),
              ),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
                maxLines: 8,
              ),
              const SizedBox(height: 20),
              if (_attachments.isNotEmpty) ...[
                const Text('Attachments:'),
                ..._attachments.map((file) => Text(file.name)).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
