import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_model.dart';
import 'email_detail.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  List<Email> _searchResults = [];
  DateTime? _startDate;
  DateTime? _endDate;
  DocumentSnapshot? _lastDocument;
  bool _isFetchingMore = false;
  bool _isAscending = false; // Flag to determine the sort order
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _searchEmails({bool isLoadMore = false}) async {
    if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    Query query = FirebaseFirestore.instance.collection('emails');

    if (_searchController.text.isNotEmpty) {
      query = query
          .where('subject', isGreaterThanOrEqualTo: _searchController.text)
          .where('subject', isLessThanOrEqualTo: _searchController.text + '\uf8ff');
    }

    if (_startDate != null && _endDate != null) {
      query = query
          .where('date', isGreaterThanOrEqualTo: _startDate)
          .where('date', isLessThanOrEqualTo: _endDate);
    }

    

    if (_lastDocument != null && isLoadMore) {
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
        if (isLoadMore) {
          _searchResults.addAll(emails);
        } else {
          _searchResults = emails;
        }
      });
    }

    setState(() {
      _isFetchingMore = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _searchEmails(isLoadMore: true);
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _searchResults.clear(); 
      _lastDocument = null; 
      _searchEmails(); 
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Emails'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _lastDocument = null; 
              _searchEmails();
            },
          ),
          IconButton(
            icon: Icon(_isAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _toggleSortOrder,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Emails',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _lastDocument = null; 
                _searchEmails();
              },
              onSubmitted: (value) {
                _lastDocument = null; 
                _searchEmails();
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectStartDate(context);
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(
                labelText: 'End Date',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectEndDate(context);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var email = _searchResults[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        email.subject,
                        style: TextStyle(
                          fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('${email.from} • ${email.body}'),
                      trailing: IconButton(
                        icon: email.isStarred ? Icon(Icons.star, color: Colors.yellow) : Icon(Icons.star_border),
                        onPressed: () {
                          setState(() {
                            email.isStarred = !email.isStarred;
                          });
                          FirebaseFirestore.instance.collection('emails').doc(email.id).update({'isStarred': email.isStarred});
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
            if (_isFetchingMore)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
