import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/models/my_user.dart';

class GradesOverviewStudent extends StatefulWidget {
  const GradesOverviewStudent({super.key});

  @override
  State<GradesOverviewStudent> createState() => _GradesOverviewStudentState();
}

class _GradesOverviewStudentState extends State<GradesOverviewStudent> {
  Map homeData = {};  //data from home
  List<Map<String, dynamic>> databaseResponse = [];  // List of all grades retrieved from the database.
  Map<String, String> subjectMap = {};   // A dictionary that groups grades by subject.
  MyUser? myUser;

  bool _isDataLoaded = false;

  Future<void> getGrades(Map homeData) async {   // Nervy a bolest
    myUser = homeData["myUser"];
    databaseResponse = await myUser?.getGradesData() ?? [];
    for (var map in databaseResponse) {   // Loops all maps of grades from database
      String mapKey = map["subject"];
      String mapValue = map["value"].toString();  // toString because its saved at a number in firebase

      // Check if the subject already exists in the Map
      if (subjectMap.containsKey(mapKey)) {
        // If it exists append the value (assuming you want to append the grades)
        subjectMap[mapKey] = "${subjectMap[mapKey]}, $mapValue";  // Append grade to existing subject value
      } else {
        // If it doesn't exist initialize it with the value from doc["value"]
        subjectMap[mapKey] = mapValue;
      }

      databaseResponse.sort((a, b) {
        Timestamp timeA = a["createdAt"] ?? Timestamp(0, 0);
        Timestamp timeB = b["createdAt"] ?? Timestamp(0, 0);
        return timeA.compareTo(timeB);
      });

    }
    if (mounted) {  // Check if the widget is still in the tree before calling setState()
      setState(() {});
    }
    }

  @override
  void didChangeDependencies() { // This method is called after initState() and guarantees that the context is fully available for use.
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      if (homeData.isEmpty) {
        homeData = ModalRoute.of(context)!.settings.arguments as Map; // Access context safely here
      }
      getGrades(homeData);
      _isDataLoaded = true;
    }

  }

  @override
  Widget build(BuildContext context) {

    List<MapEntry<String, String>> entries = subjectMap.entries.toList(); // Creates a list of entries (rows) of a Map

    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent[50],
      appBar: AppBar(
        title: Text("Student Grades"),
        backgroundColor: Colors.deepOrangeAccent[100],
      ),
      body: ListView.builder(
        itemCount: entries.length, // Number of items to display
        itemBuilder: (context, index) {
          MapEntry<String, String> entry = entries[index]; // Get the current MapEntry (key-value pair) from the list
          List<Map<String, dynamic>> mapsWithThisSubject = [];
          for (var map in databaseResponse  ) {
            if (map["subject"]== entry.key) {  // For a specific ListTile (with its own mapsWithThisSubject) and a specific entry.key (Subject - Math) get all related grates and bind it together and send onTap
              mapsWithThisSubject.add(map);
            }
          }
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              elevation: 5,
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListTile(
                leading: const Icon(Icons.class_),
                title: Text(entry.key), // This key is an attribute of the CURRENT entry
                subtitle: Text(entry.value),
                onTap: () {
                  print("You clicked ${entry.key} a ${entry.value}");
                  Navigator.pushNamed(context, "/home/grades/student/subject", arguments: {
                    "myUser" : homeData["myUser"],
                    "subject" : entry.key,
                    "gradesList" : mapsWithThisSubject,
                  });
                },

              ),
            ),
          );
        },
      ),
    );
  }
}
