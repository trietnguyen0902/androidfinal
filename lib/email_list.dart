import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mail/auth_service.dart';
import 'package:mail/email_detail.dart';
import 'email_model.dart';

class EmailList extends StatelessWidget {
  final String category;
  final String? keyword;

  EmailList({required this.category, this.keyword});

 
  final List<Email> mockEmails = [
    Email(
      id: '1',
      from: 'duy@gmail.com',
      to: 'you@gmail.com',
      subject: 'Sinh nhật',
      body: 'Ê m đi sinh nhật t vào ngày 27/12 ko cu?',
      date: DateTime.now().subtract(Duration(days: 1)),
      isRead: false,
      isStarred: false,
      labels: [],
      isTrashed: false,
    ),
    Email(
      id: '2',
      from: 'thangngu@gmail.com',
      to: 'you@gmail.com',
      subject: 'bài tập về nhà',
      body: 'ê m làm xong bài kia chưa chỉ t với, bài nó khó vãi ra!',
      date: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      isStarred: true,
      labels: [],
      isTrashed: false,
    ),
    Email(
      id: '3',
      from: 'EmIu@gmail.com',
      to: 'you@gmail.com',
      subject: 'Bầu',
      body: 'A ơi e mới thử que và nó để 2 vạch r a oi, mình sắp con đứa con đầu lòng r :3',
      date: DateTime.now().subtract(Duration(days: 1)),
      isRead: false,
      isStarred: false,
      labels: [],
      isTrashed: false,
    ),
    Email(
      id: '4',
      from: 'teacher@gmail.com',
      to: 'you@gmail.com',
      subject: 'Project',
      body: 'em xong project chưa? gửi gấp cho thầy nha sắp hét deadline r',
      date: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      isStarred: true,
      labels: [],
      isTrashed: false,
    ),
    
  ];

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('emails');
    switch (category) {
      case 'inbox':
        query = query.where('isTrashed', isEqualTo: false);
        break;
      case 'sent':
        query = query.where('from', isEqualTo: AuthService().currentUser!.email);
        break;
      case 'drafts':
        query = query.where('isDraft', isEqualTo: true);
        break;
      case 'starred':
        query = query.where('isStarred', isEqualTo: true);
        break;
      case 'trashed':
        query = query.where('isTrashed', isEqualTo: true);
        break;
    }

    if (keyword != null && keyword!.isNotEmpty) {
      query = query.where('subject', isGreaterThanOrEqualTo: keyword).where('subject', isLessThanOrEqualTo: keyword! + '\uf8ff');
    }

    return StreamBuilder(
      stream: query.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Email> emails = [];
        
        if (snapshot.hasData) {
          emails = snapshot.data!.docs.map((doc) => Email(
            id: doc['id'],
            from: doc['from'],
            to: doc['to'],
            subject: doc['subject'],
            body: doc['body'],
            date: doc['date'].toDate(),
            isRead: doc['isRead'],
            isStarred: doc['isStarred'],
            labels: List<String>.from(doc['labels']),
            isTrashed: doc['isTrashed'],
          )).toList();
        }

        // Always display mock emails
        emails.addAll(mockEmails);

        return ListView.builder(
          itemCount: emails.length,
          itemBuilder: (context, index) {
            var email = emails[index];
            return ListTile(
              title: Text(email.subject, style: TextStyle(fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold)),
              subtitle: Text('${email.from} • ${email.body}'),
              trailing: IconButton(
                icon: email.isStarred ? Icon(Icons.star, color: Colors.yellow) : Icon(Icons.star_border),
                onPressed: () {
                  // Handle star toggle
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmailDetails(email: email)),
                );
              },
            );
          },
        );
      },
    );
  }
}
