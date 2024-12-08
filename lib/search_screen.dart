import 'package:flutter/material.dart';
import 'email_list.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _keywordController,
              decoration: InputDecoration(labelText: 'Keyword'),
            ),
            TextField(
              controller: _senderController,
              decoration: InputDecoration(labelText: 'Sender'),
            ),
            // Add more filters as needed
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmailList(
                      category: 'inbox',
                      keyword: _keywordController.text,
                      // Implement additional filters as needed
                    ),
                  ),
                );
              },
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
