import 'package:flutter/material.dart';
import 'package:project/models/my_user.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  Map classListScreenData = {}; // Previous screen data
  List<Map<String, dynamic>> studentsFromClass = []; // Database response
  String className = "";
  bool _isDataLoaded = false;

  void getStudentsFromClass() async {
    MyUser myUser = classListScreenData["myUser"];
    studentsFromClass = await myUser.getStudentsFromClass(className) ?? [];
    if (mounted) {  // Check if the widget is still in the tree before calling setState()
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      if (classListScreenData.isEmpty) {
        classListScreenData = ModalRoute.of(context)!.settings.arguments as Map;
        className = classListScreenData["className"] ?? "";
      }
      getStudentsFromClass();
      _isDataLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${classListScreenData["subject"] ?? " "} - ${classListScreenData["className"] ?? " "}"),
          backgroundColor: Colors.deepOrangeAccent[100],
        ),
        body: ListView.builder(
            itemCount: studentsFromClass.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  elevation: 5,
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                        "${studentsFromClass[index]["firstName"]} ${studentsFromClass[index]["lastName"]}"),
                    onTap: () {
                      Navigator.pushNamed(context,
                          "/home/grades/teacher/classes/students/student",
                          arguments: {
                            "myUser": classListScreenData["myUser"],
                            "student": studentsFromClass[index],
                            "subject": classListScreenData["subject"],
                          });
                    },
                  ),
                ),
              );
            }));
  }
}
