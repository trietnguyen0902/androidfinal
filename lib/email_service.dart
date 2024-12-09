import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class EmailService {
  final String username;
  final String password;

  EmailService({required this.username, required this.password});

  Future<void> sendEmail({
    required String recipient,
    required String subject,
    required String body,
    List<String>? cc,
    List<String>? bcc,
    List<PlatformFile>? attachments,
  }) async {
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Your Name')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = body
      ..ccRecipients.addAll(cc ?? [])
      ..bccRecipients.addAll(bcc ?? [])
      ..attachments.addAll(attachments?.map((file) {
         if (file.path != null) {
          return FileAttachment(File(file.path!));
        } else {
          throw Exception('Unsupported file type');
        }
      }) ?? []);

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  final CollectionReference emailCollection = FirebaseFirestore.instance.collection('emails');

  Future<void> updateEmailStatus(String emailId, bool isRead) async {
    await emailCollection.doc(emailId).update({'isRead': isRead});
  }

  Future<void> moveToTrash(String emailId) async {
    await emailCollection.doc(emailId).update({'isTrashed': true});
  }

  Future<void> assignLabel(String emailId, String label) async {
    await emailCollection.doc(emailId).update({
      'labels': FieldValue.arrayUnion([label])
    });
  }

  Future<void> starEmail(String emailId, bool isStarred) async {
    await emailCollection.doc(emailId).update({'isStarred': isStarred});
  }

  Future<void> checkForNewEmails() async {
    final prefs = await SharedPreferences.getInstance();
    final autoReplyEnabled = prefs.getBool('autoReplyEnabled') ?? false;

    if (autoReplyEnabled) {
      final newEmails = await emailCollection
          .where('to', isEqualTo: username)
          .where('isRead', isEqualTo: false)
          .get();

      for (var email in newEmails.docs) {
        await sendAutoReply(email.data() as Map<String, dynamic>);
        await email.reference.update({'isRead': true});
      }
    }
  }

  Future<void> sendAutoReply(Map<String, dynamic> emailData) async {
    final autoReplyMessage = 'Thank you for your email. I am currently busy and will get back to you as soon as possible.';

    await sendEmail(
      recipient: emailData['from'],
      subject: 'Re: ${emailData['subject']}',
      body: autoReplyMessage,
    );
  }
}