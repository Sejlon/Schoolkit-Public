import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/my_user.dart';
import 'package:project/custom_widgets/submission_view.dart';

class HomeworkDetailScreen extends StatefulWidget {
  const HomeworkDetailScreen({super.key});

  @override
  State<HomeworkDetailScreen> createState() => _HomeworkDetailScreenState();
}

class _HomeworkDetailScreenState extends State<HomeworkDetailScreen> {
  late Map<String, dynamic> homework;
  late Map<String, dynamic>? submission;
  late MyUser myUser;
  final TextEditingController _answerController = TextEditingController();
  late bool isOverdue;
  bool _isDataLoaded = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    homework = args["homework"];
    myUser = args["myUser"];
    isOverdue = args["isOverdue"];
    submission = args["submission"];

    if (submission != null && submission!["isFinished"] == false && _isDataLoaded == false) {
      _answerController.text = submission!["content"] ?? "";
      _isDataLoaded= true;
    }
  }

  Future<bool> _saveDraft() async {
    // Saving a draft response (to Firestore with isFinished: false)
    DocumentReference homeworkRef = FirebaseFirestore.instance
        .collection("homeworks")
        .doc(homework["uid"]);

    bool status = await myUser.setStudentHasHomework(_answerController.text, false, homeworkRef);

    if (status) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Homework draft saved.")
        ),
      );
      Navigator.pop(context);
      return status;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("There was a problem with database connection.")
        ),
      );
      return status;
    }
  }

  Future<bool> _submitHomework() async {
    // Submitting a task (to Firestore with isFinished: true)
    DocumentReference homeworkRef = FirebaseFirestore.instance
        .collection("homeworks")
        .doc(homework["uid"]);

    bool status = await myUser.setStudentHasHomework(_answerController.text, true, homeworkRef);

    if (status) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Homework submitted.")
        ),
      );
      Navigator.pop(context);
      return status;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("There was a problem with database connection.")
        ),
      );
      return status;
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
        
              SizedBox(height: 24),
              Text(
                "Your Answer:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (submission != null)
                  SubmissionView(submission: submission!, isOverdue: isOverdue),
              if (submission == null || submission!["isFinished"] == false)
                  TextField(
                controller: _answerController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "Write your answer here...",
                  border: OutlineInputBorder(),
                ),
              ),


              if (submission == null || submission!["isFinished"] == false)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDraft,
                      child: Text("Save Draft"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitHomework,
                      style: ElevatedButton.styleFrom(backgroundColor: (isOverdue) ? Colors.red[100] : Colors.green),
                      child: Text("Submit"),
                    ),
                  ),
                  SizedBox(height: screenHeight*0.15),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

