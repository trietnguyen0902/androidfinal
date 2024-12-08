import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mail/label_service.dart';

class LabelManagementScreen extends StatefulWidget {
  @override
  _LabelManagementScreenState createState() => _LabelManagementScreenState();
}

class _LabelManagementScreenState extends State<LabelManagementScreen> {
  final LabelService _labelService = LabelService();
  final TextEditingController _labelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Labels'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _labelController,
              decoration: InputDecoration(labelText: 'New Label'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _labelService.createLabel(_labelController.text);
                _labelController.clear();
              },
              child: Text('Add Label'),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _labelService.labelCollection.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var labels = snapshot.data!.docs.map((doc) => Label(
                    id: doc.id,
                    name: doc['name'],
                  )).toList();

                  return ListView.builder(
                    itemCount: labels.length,
                    itemBuilder: (context, index) {
                      var label = labels[index];
                      return ListTile(
                        title: Text(label.name),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _labelService.deleteLabel(label.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Label {
  final String id;
  final String name;

  Label({required this.id, required this.name});
}
