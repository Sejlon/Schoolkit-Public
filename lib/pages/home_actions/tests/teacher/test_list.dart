import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/custom_widgets/test.dart';
import 'package:project/models/my_user.dart';

class TestListTeacher extends StatefulWidget {
  const TestListTeacher({super.key});

  @override
  State<TestListTeacher> createState() => _TestListTeacherState();
}

class _TestListTeacherState extends State<TestListTeacher> {

  Map screenData = {}; // Last screen data
  List<Map<String, dynamic>> testList = []; // Get tests database response
  late MyUser myUser;
  late String className;
  late String subject;
  bool _isDataLoaded = false;

  double screenHeight = 0;
  double screenWidth = 0;

  void getTests() async {
    testList = await myUser.getTests(className: className, subject:  subject) ?? [];

    try {
      // Sort from furthest to closest (descending)
      testList.sort((a, b) {
        DateTime aDate = (a["scheduledTime"] as Timestamp).toDate();
        DateTime bDate = (b["scheduledTime"] as Timestamp).toDate();
        return bDate.compareTo(aDate); // newest first
      });
    } catch (e) {
      print(e);
    }

    if (mounted) {  // Check if the widget is still in the tree before calling setState()
      setState(() {});
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "";
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000); // Dart works with milliseconds, but Firestore timestamp only has seconds
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Future<DateTime> selectDateTime() async { // Calendar and time widgets for user to choose datetime
    DateTime currentDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      //initialDate: currentDate.add(Duration(days: 1)),
      firstDate: DateTime(currentDate.year, currentDate.month, currentDate.day),
      lastDate: DateTime(2100),
    );
    TimeOfDay currentTime = TimeOfDay.now();
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,

    );

    if (pickedDate != null && pickedTime!= null) {
      return DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }
    else {
      return currentDate.add(Duration(days: 1));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;

      screenData = ModalRoute.of(context)!.settings.arguments as Map;
      myUser = screenData["myUser"];
      className = screenData["className"];
      subject = screenData["subject"];
      getTests();
      _isDataLoaded = true;
    }
  }

  void _showTestDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    late DateTime scheduledTime;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                height: screenHeight * 0.90,
                width: screenWidth * 0.85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Test',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Select date',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        scheduledTime = await selectDateTime();
                        dateController.text = _formatDateTime(scheduledTime);
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true, // Ensures label is aligned at the top
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            String name = nameController.text;
                            String description = descriptionController.text;
                            String datetime = dateController.text;

                            if (name.isNotEmpty && description.isNotEmpty && datetime.isNotEmpty) {

                              bool Status = await myUser.addTest(className, Timestamp.fromDate(scheduledTime), description, name, subject);
                              getTests();
                              print("STATUS FROM DATABASE: $Status");

                              Navigator.pop(context); // Close the dialog
                            } else if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Name is empty')),
                              );
                            } else if (description.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Description is empty')),
                              );
                            }  else if (datetime.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Date is empty')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Something is empty')),
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("$subject - $className"),
          backgroundColor: Colors.yellow[300],
        ),
        body: (testList.isEmpty)
            ? const Center(child: Text("No tests assigned"))
            : ListView.builder(
          itemCount: testList.length,
          itemBuilder: (context, index) {
            var test = testList[index];

            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 90,
                    child: Test(test: test),
                  ),
                  Flexible(
                    flex: 10,
                    child: (testList[index]["teacherID"]?.id == myUser?.uid)
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
                                  'Are you sure you want to delete this test? This action cannot be undone.'),
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
                                    status = await myUser?.deleteTest(testList[index]["uid"]) ?? false;
                                    if (status) {
                                      setState(() {
                                        testList.removeAt(index); // This will remove the item at the current index
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
                            "smula ${myUser?.shortcut} ${testList[index]["teacherShort"]}");
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
                ],
              ),
            );
          },
        ),
        floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.08),
            child: FloatingActionButton.extended(
              label: const Text("Add Test"),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.yellow[600],
              onPressed: () {
                _showTestDialog();
              },
            )
        )
    );
  }
}