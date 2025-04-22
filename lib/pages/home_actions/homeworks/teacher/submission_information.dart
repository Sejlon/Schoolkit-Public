import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/my_user.dart';
import 'package:project/custom_widgets/submission_view.dart';

class SubmissionInformation extends StatefulWidget {
  const SubmissionInformation({super.key});

  @override
  State<SubmissionInformation> createState() => _SubmissionInformationState();
}

class _SubmissionInformationState extends State<SubmissionInformation> {
  late Map<String, dynamic> homework;
  late Map<String, dynamic>? submission;
  late MyUser myUser;
  late Map<String, dynamic> student;
  bool isOverdue = false;
  bool _isDataLoaded = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isDataLoaded == false) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      homework = args["homework"];
      myUser = args["myUser"];
      student = args["student"];
      submission = args["submission"];
      isOverdue = args["isOverdue"];
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text(homework["name"] ?? "Homework Detail"),
          backgroundColor: Colors.lightGreen[200]
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Description:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "created at: ${_formatTimestamp(homework["createdAt"]) ?? "Loading.."}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    )
                  ]
              ),
              SizedBox(height: 8),
              Text(homework["description"] ?? "No description"),

              SizedBox(height: 24),
              Text(
                "Teacher: ${homework["teacherShort"] ?? "Loading.."}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                "Deadline: ${_formatTimestamp(homework["deadline"]) ?? "Loading.."}",
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Student:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(student["firstName"] ?? "-"),
                  Text(student["lastName"] ?? "-"),
                  Text(student["email"] ?? "-"),
                  Text(student["class"] ?? "-"),

                ],
              ),




              SizedBox(height: 24),
              Text(
                "Answer:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              (submission != null && (submission!["isFinished"] ?? false))
                  ? SubmissionView(submission: submission!, isOverdue: isOverdue)
                  : Card(
                color: Colors.red[50],
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text("Not Submitted"),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

