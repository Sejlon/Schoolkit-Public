import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TestInformation extends StatefulWidget {
  const TestInformation({super.key});

  @override
  State<TestInformation> createState() => _TestInformationState();
}

class _TestInformationState extends State<TestInformation> {
  late Map<String, dynamic> test;
  bool _isDataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      test = args["test"];
      _isDataLoaded = true;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Unknown";
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(test["name"] ?? "Test Detail"),
        backgroundColor: Colors.yellow[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),

                Text("Created: ${_formatTimestamp(test["createdAt"])}", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            SizedBox(height: 6),
            Text(test["description"] ?? "-"),
            SizedBox(height: 24),
            Text("Scheduled Time: ${_formatTimestamp(test["scheduledTime"])}", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Text("Teacher: ${test["teacherShort"] ?? "-"}", style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 3),
            Text("Subject: ${test["subject"] ?? "-"}"),
            SizedBox(height: 3),
            Text("Class: ${test["class"] ?? "-"}"),


          ],
        ),
      ),
    );
  }
}
