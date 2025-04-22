import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/my_user.dart';

class SeeGrade extends StatefulWidget {
  const SeeGrade({super.key});

  @override
  State<SeeGrade> createState() => _SeeGradeState();
}

class _SeeGradeState extends State<SeeGrade> {
  Map gradeData = {}; // From screenData extracted grade information
  Map screenData = {};

  String teacherFirstName="Loading...     ";
  String teacherLastName= "";
  String teacherEmail= "Loading...     ";
  String teacherShortcut= "Shortcut";

  late MyUser myUser;
  bool _isDataLoaded = false;
  double screenHeight = 0;
  double screenWidth = 0;

  // Convert Firestore Timestamp to a formatted DateTime string
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();  // Convert to DateTime
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);  // Format it with requirements
  }

 void teacherData(String role) async{
    teacherShortcut = gradeData["teacherShort"];

    if (role=="Teacher" && myUser.shortcut==gradeData["teacherShort"]) {
      teacherFirstName=myUser.firstName;
      teacherLastName=myUser.lastName;
      teacherEmail=myUser.email;
    } else if (role=="Student" || role=="Teacher") {
      Map<String, dynamic>? teacherMap = await myUser.getOthersUserData(gradeData["teacherID"]);
      if (teacherMap != null && teacherMap.isNotEmpty) {
        teacherFirstName=teacherMap["firstName"];
        teacherLastName=teacherMap["lastName"];
        teacherEmail=teacherMap["email"];
      }
    }
    if (mounted) {  // Check if the widget is still in the tree before calling setState()
      setState(() {});
    }
 }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isDataLoaded == false) {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
      if (screenData.isEmpty) {
        screenData = ModalRoute.of(context)!.settings.arguments as Map;
        myUser = screenData["myUser"];
        gradeData = screenData["gradeMap"];
        _isDataLoaded = true;
      }
      teacherData(myUser.role);
    }
    print("Here is screen data: \n");
    print(screenData);
  }

  @override
  Widget build(BuildContext context) {
    Timestamp? createdAt = gradeData["createdAt"];
    int gradeValue = gradeData["value"] ?? 5;

    double progress = (6 - gradeValue)/ 5.0;    // For the linear bar

    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent[50],
      appBar: AppBar(
        title: const Text("Grade Overview"),
        backgroundColor: Colors.deepOrangeAccent[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row for Grade & Teacher (using Row for side-by-side display)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Grade Section (with badge design)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Grade",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                gradeData["value"].toString() ?? "Unknown",
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Teacher Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Teacher",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            // Teacher name, email, and staff ID
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.deepOrangeAccent, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      "$teacherFirstName $teacherLastName",
                                      style: const TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis, // Handles overflow
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.email, color: Colors.deepOrangeAccent, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      teacherEmail,
                                      style: const TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis, // Handles overflow
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.badge, color: Colors.deepOrangeAccent, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      teacherShortcut,
                                      style: const TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis, // Handles overflow
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Subject and Message
                    Text(
                      "Subject: ${gradeData["subject"] ?? "Unknown"}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Message: ${gradeData["message"] ?? "Unknown"}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "When: ${createdAt != null ? formatTimestamp(createdAt) : "Unknown"}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Performance: ",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),  // Set the border radius to make the edges rounded
                            child: LinearProgressIndicator(
                              value: progress,  // value between 0.0 and 1.0 (0 is empty, 1 is full)
                              backgroundColor: Colors.grey[300],  // Background color of the progress bar
                              color: Colors.deepOrangeAccent,
                              minHeight: 8,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
