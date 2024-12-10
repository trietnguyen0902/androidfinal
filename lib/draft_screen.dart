import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_model.dart';
import 'compose_email_screen.dart';

class DraftsScreen extends StatelessWidget {
  const DraftsScreen({super.key});

  Future<void> _deleteDraft(BuildContext context, Email draft) async {
    await FirebaseFirestore.instance.collection('emails').doc(draft.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drafts'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('emails')
            .where('from', isEqualTo: user?.email)
            .where('isDraft', isEqualTo: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final drafts = snapshot.data!.docs.map((doc) {
            final email = Email(
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
            );
            return email;
          }).toList();

          // Filter out mock emails from the drafts
          final realDrafts = drafts.where((email) => !email.id.startsWith('mock-')).toList();

                    return ListView.builder(
            itemCount: realDrafts.length,
            itemBuilder: (context, index) {
              var draft = realDrafts[index];
              return ListTile(
                title: Text(draft.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(draft.body),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteDraft(context, draft),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ComposeEmailScreen(draft: draft)),
                 );
                },
              );
            },
          );
        },
      ),
    );
  }
}
