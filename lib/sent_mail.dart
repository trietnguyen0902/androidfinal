import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_model.dart';
import 'email_detail.dart';


class SentMail extends StatefulWidget {
  const SentMail({super.key});

  @override
  _SentMailState createState() => _SentMailState();
}

class _SentMailState extends State<SentMail> {
  List<Email> _sentEmails = [];
  DocumentSnapshot? _lastDocument;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchSentEmails();
  }

  Future<void> _fetchSentEmails({bool refresh = false}) async {
    if (_isFetchingMore) return;

    if (refresh) {
      _sentEmails.clear();
      _lastDocument = null;
    }

    setState(() {
      _isFetchingMore = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('emails')
        .where('from', isEqualTo: 'your_email@gmail.com')
        .where('isDraft', isEqualTo: false) // Ensure not fetching drafts
        .where('isTrashed', isEqualTo: false); // Ensure not fetching trashed emails
       

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;

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
        _sentEmails.addAll(emails);
      });
    }

    setState(() {
      _isFetchingMore = false;
    });
  }

 

  Future<void> _showConfirmationDialog(Email email) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to move this email to trash?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _trashEmail(email);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _trashEmail(Email email) async {
    try {
      await FirebaseFirestore.instance.collection('emails').doc(email.id).update({'isTrashed': true});
      setState(() {
        _sentEmails.remove(email);
      });
    } catch (e) {
      print('Error trashing email: $e');
    }
  }

  Future<void> _starEmail(Email email) async {
    try {
      await FirebaseFirestore.instance.collection('emails').doc(email.id).update({'isStarred': !email.isStarred});
      setState(() {
        email.isStarred = !email.isStarred;
      });
    } catch (e) {
      print('Error starring email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sent Mail'),
        backgroundColor: Colors.redAccent,
      
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _sentEmails.length + 1,
                itemBuilder: (context, index) {
                  if (index == _sentEmails.length) {
                    return _isFetchingMore
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () => _fetchSentEmails(refresh: true),
                            child: const Text('Load More'),
                          );
                  }

                  var email = _sentEmails[index];
                  return Card(
                    child: ListTile(
                      title: Text(email.subject, style: TextStyle(fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text('${email.to} • ${email.body}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: email.isStarred ? const Icon(Icons.star, color: Colors.yellow) : const Icon(Icons.star_border),
                            onPressed: () => _starEmail(email),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showConfirmationDialog(email);
                            },
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
            if (_isFetchingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         
        
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
