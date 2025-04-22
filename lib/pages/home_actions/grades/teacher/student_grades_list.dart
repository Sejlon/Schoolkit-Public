import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/models/my_user.dart';

class StudentGradesList extends StatefulWidget {
  const StudentGradesList({super.key});

  @override
  State<StudentGradesList> createState() => _StudentGradesListState();
}

class _StudentGradesListState extends State<StudentGradesList> {
  Map studentListData = {}; // Data from previous screen
  List<Map<String, dynamic>> databaseResponse = []; // Database response
  Map<String, dynamic> studentMap = {}; // Info about the selected student
  bool _isDataLoaded = false;
  late MyUser myUser;

  double screenHeight = 0;
  double screenWidth = 0;

  Future<void> getStudentGrades() async {
    String subject = studentListData["subject"];
    databaseResponse = await myUser.getGradesData(
            studentUID: studentMap["uid"], subject: subject) ??
        [];
    print(
        "Screen student_grades_list function getStudentGrades ${databaseResponse} ${studentMap}");

    databaseResponse.sort((a, b) {
      Timestamp timeA = a["createdAt"] ?? Timestamp(0, 0);
      Timestamp timeB = b["createdAt"] ?? Timestamp(0, 0);
      return timeA.compareTo(timeB);
    });

    if (mounted) {  // Check if the widget is still in the tree before calling setState()
      setState(() {});
    }
  }

  Icon _getGradeIcon(num weight) {
    // num - Works with double AND int   if grade is whole it will be an int, else float
    if (weight <= 1) {
      return Icon(Icons.school_outlined, color: Colors.black54); // Small weight
    } else if (weight <= 3) {
      return Icon(Icons.school_rounded, color: Colors.black54); // Medium weight
    } else {
      return Icon(Icons.school, color: Colors.black); // High weight
    }
  }

  String formatNumber(double number) {
    return number % 1 == 0
        ? number.toInt().toString()
        : number.toString().replaceAll('.', ',');
  }

  Widget getGradesWeightedAverage(List<Map<String, dynamic>> databaseResponse) {
    if (databaseResponse.isEmpty) {
      return Text("No grades", style: TextStyle(fontSize: 10));
    }

    double weightedValue = 0.0;
    double totalWeight = 0.0;

    List graphicValue = [];
    List graphicWeight = [];

    for (var doc in databaseResponse) {
      int value = (doc["value"] ?? 0).toInt();
      double weight = (doc["weight"] ?? 1).toDouble();

      weightedValue += value * weight;
      totalWeight += weight;

      graphicValue.add("$value*${formatNumber(weight)}");
      graphicWeight.add(formatNumber(weight));
    }
    double average = (totalWeight > 0) ? (weightedValue / totalWeight) : 0;

    String finalValue = graphicValue.join(" + ");
    String finalWeight = graphicWeight.join(" + ");

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                finalValue,
                style: TextStyle(fontSize: 12),
              ),
              Divider(
                  thickness: 1,
                  color: Colors.black,
                  height: screenHeight * 0.01),
              Text(
                finalWeight,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text("="),
        SizedBox(width: 8),
        Text(average.toStringAsFixed(2)),
      ],
    );
  }

  void _showGradeDialog() {
    TextEditingController valueController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              height: screenHeight * 0.90, // Adjust height based on your needs
              width: screenWidth * 0.85, // Adjust width as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Grade',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  // Grade input field
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Message input field
                  TextField(
                    controller: valueController,
                    keyboardType:
                        TextInputType.number, // Shows number keyboard for user
                    decoration: InputDecoration(
                      labelText: 'Grade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: weightController,
                    keyboardType:
                        TextInputType.number, // Shows number keyboard for user
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Buttons (Save & Cancel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String message = messageController.text;
                          String value = valueController.text;
                          String weight = weightController.text;
                          weight = weight.replaceAll(",", ".");

                          int gradeValue = int.tryParse(value) ?? 0;
                          double weightValue = double.tryParse(weight) ?? 0;
                          if (value.isNotEmpty &&
                              message.isNotEmpty &&
                              weight.isNotEmpty &&
                              gradeValue != 0 &&
                              weightValue != 0) {
                            if (gradeValue != 1 && gradeValue != 2 && gradeValue != 3 && gradeValue != 4 && gradeValue != 5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Value must be a number from 1 - 5')),
                              );
                              return;
                            }

                            String subject = studentListData["subject"];
                            String studentID = studentMap["uid"];
                            DocumentReference studentRef = FirebaseFirestore.instance.collection('users').doc(studentID);
                            print("Message: $message");
                            print("Grade: $gradeValue");
                            print("Weight: $weightValue");
                            bool Status = await myUser?.addGrade(message, gradeValue, weightValue, studentRef, subject) ?? false;
                            getStudentGrades();
                            print("STATUS FROM DATABASE: $Status");

                            Navigator.pop(context); // Close the dialog
                          } else if (gradeValue == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Grade must be a whole number')),
                            );
                          } else if (weightValue == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Weight must be a valid number')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please fill in all fields')),
                            );
                          }
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    // This method is called after initState() and guarantees that the context is fully available for use.
    super.didChangeDependencies();
    if (_isDataLoaded == false) {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
      if (studentListData.isEmpty) {
        studentListData = ModalRoute.of(context)!.settings.arguments as Map;
        studentMap = studentListData["student"] ?? {};
        myUser = studentListData["myUser"];

        getStudentGrades();
        _isDataLoaded = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent resizing when keyboard appears
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
            "${studentMap["firstName"] ?? " "} ${studentMap["lastName"] ?? ""} - ${studentListData["subject"] ?? ""}"),
        backgroundColor: Colors.deepOrangeAccent[100],
      ),
      body: Column(children: [
        Expanded(
          child: (databaseResponse.isEmpty) ? Center(child: Text("No grades available")) : ListView.builder(
            itemCount: databaseResponse.length, // Number of items to display
            itemBuilder: (context, index) {
              //final student = gradesList[index];
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(children: [
                  Flexible(
                    flex: 90,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ListTile(
                        leading: _getGradeIcon(databaseResponse[index]["weight"]),
                        title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  (databaseResponse[index]["message"]
                                              .length >
                                          21)
                                      ? "${databaseResponse[index]["message"].substring(0, 20)}.."
                                      : databaseResponse[index]
                                          ["message"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text(
                                  "weight: ${databaseResponse[index]["weight"] ?? " "}x",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: "Lato",
                                  ))
                            ]),
                        subtitle: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(databaseResponse[index]["value"]
                                .toString()),
                            Text(databaseResponse[index]
                                    ["teacherShort"] ??
                                " "),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                              context, "/home/grades/seeGrade",
                              arguments: {
                                "myUser": myUser,
                                "gradeMap": databaseResponse[index],
                                "subject": studentListData["subject"],
                              });
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: (databaseResponse[index]["teacherID"]?.id == myUser?.uid)
                        ? OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side:
                                  BorderSide(color: Colors.red, width: 1),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text(
                                        'Are you sure you want to delete this grade? This action cannot be undone.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          bool status;
                                          status = await myUser?.deleteGrade(databaseResponse[index]["uid"]) ?? false;
                                          if (status) {
                                            setState(() {
                                              databaseResponse.removeAt(index); // This will remove the item at the current index
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Deletion successful")),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Deletion failed")),
                                            );
                                          }
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Confirm'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Center(
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          )
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side: BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            onPressed: () {
                              print(
                                  "smula ${myUser?.shortcut} ${databaseResponse[index]["teacherShort"]}");
                            },
                            child: Center(
                              child: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                  )
                ]),
              );
            },
          ),
        ),

              // Here is the strip
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(13),
                color: Colors.grey[300],
                child:
                    Center(child: (databaseResponse.isNotEmpty)
                        ? getGradesWeightedAverage(databaseResponse)
                        : Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text("No grades available"),
                    )),
              ),
            ]),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.08),
        child: FloatingActionButton.extended(
          onPressed: () {
            _showGradeDialog();
          },
          icon: Icon(Icons.add),
          label: const Text("Add Grade"),
          backgroundColor: Colors.deepOrangeAccent,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Position it bottom-right
    );
  }
}
