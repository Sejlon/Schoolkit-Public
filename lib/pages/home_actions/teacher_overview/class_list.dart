import 'package:flutter/material.dart';

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  Map overviewScreenData = {};
  List<String> classList = [];
  bool _isDataLoaded = false;
  int action = 0;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      if (overviewScreenData.isEmpty) {
        overviewScreenData = ModalRoute.of(context)!.settings.arguments as Map;
        classList = overviewScreenData["classesWithThisSubject"]?? [];
        action = overviewScreenData["action"];
      }
      _isDataLoaded = true;
    }
  }

  Color getAppBarColor() {
    if (action == 1) {
      return Colors.deepOrangeAccent[100]!;
    } else if (action == 2) {
      return Colors.lightGreen[200]!;
    } else if (action == 3) {
      return Colors.yellow[300]!;
    }
    return Colors.deepOrangeAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(overviewScreenData["subject"] ?? " "),
          backgroundColor: getAppBarColor(),
        ),
      body: ListView.builder(
      itemCount: classList.length,
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
              leading: const Icon(Icons.group),
              title: Text(classList[index]),
              onTap: () {
                if (action == 1) {
                  Navigator.pushNamed(context, "/home/grades/teacher/classes/students", arguments: {
                    "myUser" : overviewScreenData["myUser"],
                    "className" : classList[index],
                    "subject" : overviewScreenData["subject"],
                  });
                } else if (action == 2) {
                  Navigator.pushNamed(context, "home/homeworks/teacher/homework_list", arguments: {
                    "myUser" : overviewScreenData["myUser"],
                    "className" : classList[index],
                    "subject" : overviewScreenData["subject"],
                  });
                } else if (action == 3) {
                  Navigator.pushNamed(context, "home/tests/teacher", arguments: {
                    "myUser" : overviewScreenData["myUser"],
                    "className" : classList[index],
                    "subject" : overviewScreenData["subject"],
                  });
                }




                }
            ),
          ),
        );
    }
      )
      );
  }
}
