import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_model.dart';
import 'email_detail.dart';

class EmailList extends StatefulWidget {
  final String category;
  final String? keyword;

  EmailList({required this.category, this.keyword});

  @override
  _EmailListState createState() => _EmailListState();
}

class _EmailListState extends State<EmailList> {
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
      isDraft: false, 
    ),
    Email(
      id: '2',
      from: 'thangngu@gmail.com',
      to: 'you@gmail.com',
      subject: 'Bài tập về nhà',
      body: 'ê m làm xong bài kia chưa chỉ t với, bài nó khó vãi ra!',
      date: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      isStarred: false,
      labels: [],
      isTrashed: false,
      isDraft: false, 
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
      isDraft: false, 
    ),
    Email(
      id: '4',
      from: 'teacher@gmail.com',
      to: 'you@gmail.com',
      subject: 'Project',
      body: 'em xong project chưa? gửi gấp cho thầy nha sắp hết deadline r',
      date: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      isStarred: false,
      labels: [],
      isTrashed: false,
      isDraft: false, 
    ),
     Email(
      id: '5',
      from: 'parents@gmail.com',
      to: 'you@gmail.com',
      subject: 'Tết',
      body: 'Tết này con có vè quê chơi k con? nếu có thì nhớ dẫn bồ con về giới thiệu cho cả nhà luôn nhé',
      date: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      isStarred: false,
      labels: [],
      isTrashed: false,
      isDraft: false, 
    ),
     Email(
      id: '6',
      from: 'anh@gmail.com',
      to: 'you@gmail.com',
      subject: 'Tiền nợ',
      body: 'ê bữa m còn nợ t 500k nhớ trả nha, STK: 12313125152, Vietcombank',
      date: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      isStarred: false,
      labels: [],
      isTrashed: false,
      isDraft: false, 
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('emails');
    switch (widget.category) {
      case 'inbox':
        query = query.where('to', isEqualTo: FirebaseAuth.instance.currentUser!.email).where('isTrashed', isEqualTo: false);
        break;
      case 'sent':
        query = query.where('from', isEqualTo: FirebaseAuth.instance.currentUser!.email);
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

    if (widget.keyword != null && widget.keyword!.isNotEmpty) {
      query = query.where('subject', isGreaterThanOrEqualTo: widget.keyword).where('subject', isLessThanOrEqualTo: widget.keyword! + '\uf8ff');
    }

    return StreamBuilder(
      stream: query.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<Email> emails = snapshot.data!.docs.map((doc) => Email(
          id: doc.id,
          from: doc['from'],
          to: doc['to'],
          subject: doc['subject'],
          body: doc['body'],
          date: doc['date'].toDate(),
          isRead: doc['isRead'],
          isStarred: doc['isStarred'],
          labels: List<String>.from(doc['labels']),
          isTrashed: doc['isTrashed'],
          isDraft: doc['isDraft'],
        )).toList();

        
        if (widget.category != 'trashed' && widget.category != 'drafts') {
          if (widget.category == 'starred') {
            emails.addAll(mockEmails.where((email) => email.isStarred));
          } else {
            emails.addAll(mockEmails);
          }
        }

        return ListView.builder(
          itemCount: emails.length,
          itemBuilder: (context, index) {
            var email = emails[index];
            return Card(
              child: ListTile(
                title: Text(email.subject, style: TextStyle(fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text('${email.from} • ${email.body}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmailDetails(email: email)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
