import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_model.dart';
import 'email_detail.dart';

class StarredMail extends StatefulWidget {
  const StarredMail({super.key});

  @override
  _StarredMailState createState() => _StarredMailState();
}

class _StarredMailState extends State<StarredMail> {
  List<Email> _starredEmails = [];
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchStarredEmails();
  }

  Future<void> _fetchStarredEmails() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('emails')
        .where('isStarred', isEqualTo: true)
        .where('isTrashed', isEqualTo: false); // Ensure not fetching trashed emails

    QuerySnapshot querySnapshot = await query.get();

       if (querySnapshot.docs.isNotEmpty) {
      List<Email> emails = querySnapshot.docs.map((doc) => Email(
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

      setState(() {
        _starredEmails.addAll(emails);
      });
    }

    setState(() {
      _isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starred Mail'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStarredEmails,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _starredEmails.length,
                itemBuilder: (context, index) {
                  var email = _starredEmails[index];
                  return Card(
                    child: ListTile(
                      title: Text(email.subject, style: TextStyle(fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text('${email.from} • ${email.body}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('emails').doc(email.id).update({'isStarred': false});
                          setState(() {
                            _starredEmails.remove(email);
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EmailDetails(email: email)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            if (_isFetching)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
