import 'package:flutter/material.dart';
import 'package:project/models/my_user.dart';

class OverviewTeacher extends StatefulWidget {
  const OverviewTeacher({super.key});

  @override
  State<OverviewTeacher> createState() => _OverviewTeacherState();
}

class _OverviewTeacherState extends State<OverviewTeacher> {
  Map homeData = {};
  Map<String, String> subjectMap = {};
  List<Map<String, dynamic>> databaseResponse = [];
  int action = 0;
  bool _isDataLoaded = false;
  MyUser? myUser;

  void getTeacherClasses() async {
    myUser = homeData["myUser"];
    action = homeData["action"];
    databaseResponse = await myUser?.getTeacherHasClasses() ?? [];
    for (var doc in databaseResponse) {
      String mapKey = doc["subject"];
      String mapValue = doc["class"];

      if (subjectMap.containsKey(mapKey)) {
        subjectMap[mapKey] = "${subjectMap[mapKey]}, $mapValue";  // Append to existing value
      } else {
        // If it doesn't exist initialize it with the value
        subjectMap[mapKey] = mapValue;
      }
    }
    if (mounted) {  // Check if the widget is still in the tree before calling setState() (if i called a function with set state and closed the page it would still execute setstate => throw an error)
      setState(() {});
    }
    print(subjectMap);
  }


  @override
  void didChangeDependencies() {
    // This method is called after initState() and guarantees that the context is fully available for use.
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      if (homeData.isEmpty) {
        homeData = ModalRoute  //Gets myUser
            .of(context)!
            .settings
            .arguments as Map; // Access context safely here
      }
      getTeacherClasses();
      _isDataLoaded = true;
    }
  }

  String getAppBarTitle() {
    if (action == 1) return "Teacher Grades";
    if (action == 2) return "Teacher Homeworks";
    if (action == 3) return "Teacher Tests";
    return "";
  }

  Color getAppBarColor() {
    if (action == 1) return Colors.deepOrangeAccent[100]!;
    if (action == 2) return Colors.lightGreen[200]!;
    if (action == 3) return Colors.yellow[300]!;
    return Colors.deepOrangeAccent;
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, String>> entries = subjectMap.entries.toList(); // Creates a list of entries (rows) of a Map
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent[50],
      appBar: AppBar(
        backgroundColor: getAppBarColor(),
        title: Text(getAppBarTitle()),
      ),
      body: ListView.builder(
        itemCount: subjectMap.length, // Number of items to display
        itemBuilder: (context, index) {
          MapEntry<String, String> entry = entries[index]; // Get the current entry (key-value pair) from the list
          List<String> classesWithThisSubject = [];
          for (var map in databaseResponse ) {
            if (map["subject"]== entry.key) {  // For a specific ListTile (with its own mapsWithThisSubject) and a specific entry.key (Subject - Math) get all related grates and bind it together and send onTap
              classesWithThisSubject.add(map["class"]);
            }
          }
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              elevation: 5,
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListTile(
                leading: const Icon(Icons.class_),
                title: Text(entry.key),
                subtitle: Text(entry.value),
                onTap: () {
                    Navigator.pushNamed(context, "/home/teacher/classes", arguments: {
                      "myUser" : homeData["myUser"],
                      "classesWithThisSubject" : classesWithThisSubject,
                      "subject" : entry.key,
                      "action" : action,
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