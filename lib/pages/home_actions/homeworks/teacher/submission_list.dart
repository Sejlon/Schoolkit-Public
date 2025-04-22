import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:project/models/my_user.dart";

class SubmissionList extends StatefulWidget {
  const SubmissionList({super.key});

  @override
  State<SubmissionList> createState() => _SubmissionListState();
}

class _SubmissionListState extends State<SubmissionList> {
  Map screenData = {};
  List<Map<String, dynamic>> databaseResponse = [];
  List<Map<String, dynamic>> studentList = [];
  late Map<String, dynamic> homework;
  late MyUser myUser;
  bool _isDataLoaded = false;
  int submissionCounter = 0;

  Future<void> getSubmissionsByHomework() async {
    DocumentReference homeworkRef = FirebaseFirestore.instance
        .collection("homeworks")
        .doc(homework["uid"]);
    databaseResponse = await myUser.getSubmissionsByHomework(homeworkRef) ?? [];

    submissionCounter = databaseResponse.where((sub) => sub['isFinished'] == true).length;

    if (mounted) {  // Check if the widget is still in the tree before calling setState()
      setState(() {});
    }
  }

  bool checkIfHomeworkIsOverdue(Map<String, dynamic> homework) {
    DateTime handedInTime = DateTime.now();

    for (var submission in databaseResponse) {
      if (submission["homeworkID"].id == homework["uid"]) {
        handedInTime = (submission["handedIn"]).toDate();
        break;
      }
    }
    Timestamp? deadlineTimestamp = homework["deadline"];
    if (deadlineTimestamp != null) {
      DateTime deadline = deadlineTimestamp.toDate();
      if (deadline.isBefore(handedInTime)) {
        return true;
      }
    }
    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {

      screenData = ModalRoute.of(context)!.settings.arguments as Map;
      myUser = screenData["myUser"];
      homework = screenData["homework"];
      studentList = screenData["studentList"];
      studentList.sort((a, b) => a['lastName'].compareTo(b['lastName'])); // Sorts students by alphabet from A to Z
      _isDataLoaded = true;
      getSubmissionsByHomework();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Submissions"),
        backgroundColor: Colors.lightGreen[200],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: studentList.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> student = studentList[index];
                final Map<String, dynamic> submission = databaseResponse.firstWhere( // Uses 2 anon functions as parameters
                        (sub) => sub['studentID'].id == student['uid'],  // This function is run on each 'sub' (submission) in the list. When an element returns true, firstWhere returns that element.
                    orElse: () => {}   // If no matching submission is found, return an empty map instead of throwing an error.
                );

                bool isSubmitted = submission.isNotEmpty && (submission['isFinished'] ?? false);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      '${student['firstName']} ${student['lastName']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Class: ${student['class']}'),
                        Text('Email: ${student['email']}'),
                        Text(
                          'Submission: ${isSubmitted ? "Submitted" : "Not Submitted"}',
                          style: TextStyle(
                            color: isSubmitted ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      isSubmitted ? Icons.check_circle : Icons.cancel,
                      color: isSubmitted ? Colors.green : Colors.red,
                    ),
                    onTap: () {
                      Navigator.pushNamed( context, "home/homeworks/teacher/homework_list/submissions/details", arguments: {
                        "myUser": myUser,
                        "homework": homework,
                        "submission" : submission,
                        "student" : studentList[index],
                        "isOverdue" : checkIfHomeworkIsOverdue(homework),
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            color: Colors.lightGreen[200],
            child: Center(
              child: Text(
                "Total Submissions: $submissionCounter",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
