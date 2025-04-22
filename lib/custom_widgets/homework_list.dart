import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/my_user.dart';

class HomeworkList extends StatelessWidget {
  final String status;
  final List<Map<String, dynamic>> homeworks;
  final List<Map<String, dynamic>> studentSubmissions;
  MyUser myUser;

  HomeworkList(
      {super.key,
      required this.status,
      required this.homeworks,
      required this.studentSubmissions,
      required this.myUser});

  bool checkIfHomeworkIsOverdue(Map<String, dynamic> homework) {
    DateTime handedInTime = DateTime.now();

    for (var submission in studentSubmissions) {
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

  // Future<Map<String,dynamic>?> getTeacherInformation(Map<String, dynamic> homework) async {   //TODO tohle se bude hodit u podrobnosti domacich ukolu
  //   Map<String,dynamic> teacherDoc = await myUser.getOthersUserData(homework["teacherID"]) ?? {};
  //   return teacherDoc;
  // }

  // Method to format Timestamp to a readable string
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Unknown";
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Map<String, dynamic>? findSubmission(Map<String, dynamic> hw) {
    for (var submission in studentSubmissions) {
      if (submission["homeworkID"].id == hw["uid"]) {
        return submission;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredHomeworks = [];

    if (status == "Finished") {
      print("Current tab status: $status");
      for (var submission in studentSubmissions) {
        for (var hw in homeworks) {
          if (submission["homeworkID"].id == hw["uid"] && submission["isFinished"] == true) {
            print("\n Nasel se Submission!     ${hw}  ${submission}");
            filteredHomeworks.add(hw);
          }
        }
      }
    } else if (status == "Unfinished") {
      //Basically
      print("Current tab status: $status");
      for (var hw in homeworks) {
        bool foundMatch = false;
        for (var submission in studentSubmissions) {
          // Check if submission is for the current homework not finished and not overdue
          if (submission["homeworkID"].id == hw["uid"] && submission["isFinished"] == false && !checkIfHomeworkIsOverdue(hw)) {
            filteredHomeworks.add(hw);
            foundMatch = true;
          } else if (submission["homeworkID"].id == hw["uid"] && submission["isFinished"] == true) {
            foundMatch = true;
          }
        }
        // If no matching submission was found and the homework is not overdue, add it to the filtered list
        if (!foundMatch && !checkIfHomeworkIsOverdue(hw)) {
          filteredHomeworks.add(hw);
        }
      }
    } else if (status == "Overdue") {
      // Same as "Unfinished" only difference is removing negation of checkIfHomeworkIsOverdue method
      print("Current tab status: $status");
      for (var hw in homeworks) {
        bool foundMatch = false;
        for (var submission in studentSubmissions) {
          if (submission["homeworkID"].id == hw["uid"] && submission["isFinished"] == false && checkIfHomeworkIsOverdue(hw)) {
            filteredHomeworks.add(hw);
            foundMatch = true;
          } else if (submission["homeworkID"].id == hw["uid"] &&
              submission["isFinished"] == true) {
            foundMatch = true;
          }
        }
        if (!foundMatch && checkIfHomeworkIsOverdue(hw)) {
          filteredHomeworks.add(hw);
        }
      }
    }

    return (filteredHomeworks.isEmpty)
        ? Center(child: Text('No $status homeworks available'))
        : ListView.builder(
            itemCount: filteredHomeworks.length,
            itemBuilder: (context, index) {
              var hw = filteredHomeworks[index];
              Map<String, dynamic>? hwSubmission = findSubmission(hw);

              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: (checkIfHomeworkIsOverdue(hw)) ? Colors.red[100] : Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: ListTile(
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (hw["name"] != null && hw["name"].length > 23) ? "${hw["name"].substring(0, 22)}.." : hw["name"] ?? "No Title",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (checkIfHomeworkIsOverdue(hw))
                            Text(
                              "  Late",
                              style: TextStyle(color: Colors.red),
                            ),
                        ]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((hw["description"] != null &&
                                hw["description"].length > 68)
                            ? "${hw["description"].substring(0, 67)}.."
                            : hw["description"] ?? "No Description"),
                        SizedBox(height: 4),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Teacher: ${hw["teacherShort"]}",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "Due: ${_formatTimestamp(hw["deadline"])}",
                                style: TextStyle(
                                    fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ]),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "home/homeworks/student/seeHomework",
                          arguments: {
                            "myUser": myUser,
                            "homework": hw,
                            "isOverdue": checkIfHomeworkIsOverdue(hw),
                            if (hwSubmission != null)
                              "submission": hwSubmission,
                          });
                    },
                  ),
                ),
              );
            },
          );
  }
}
