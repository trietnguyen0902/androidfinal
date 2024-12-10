import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_model.dart';
import 'email_detail.dart';

class TrashMailScreen extends StatefulWidget {
  const TrashMailScreen({super.key});

  @override
  _TrashMailScreenState createState() => _TrashMailScreenState();
}

class _TrashMailScreenState extends State<TrashMailScreen> {
  List<Email> _trashedEmails = [];
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchTrashedEmails();
  }

  Future<void> _fetchTrashedEmails() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('emails')
        .where('isTrashed', isEqualTo: true);

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
        _trashedEmails.addAll(emails);
      });
    }

    setState(() {
      _isFetching = false;
    });
  }

  Future<void> _restoreEmail(Email email) async {
    try {
      await FirebaseFirestore.instance.collection('emails').doc(email.id).update({'isTrashed': false});
      setState(() {
        _trashedEmails.remove(email);
      });
    } catch (e) {
      print('Error restoring email: $e');
    }
  }

  Future<void> _deleteEmailPermanently(Email email) async {
    try {
      await FirebaseFirestore.instance.collection('emails').doc(email.id).delete();
      setState(() {
        _trashedEmails.remove(email);
      });
    } catch (e) {
      print('Error deleting email permanently: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTrashedEmails,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _trashedEmails.length,
                itemBuilder: (context, index) {
                  var email = _trashedEmails[index];
                  return Card(
                    child: ListTile(
                      title: Text(email.subject, style: TextStyle(fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text('${email.from} • ${email.body}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore),
                            onPressed: () => _restoreEmail(email),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteEmailPermanently(email),
                          ),
                        ],
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
