import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/models/my_user.dart';
import 'package:project/custom_widgets/homework_list.dart';
import 'package:project/main.dart';

class HomeworkOverviewStudent extends StatefulWidget {
  const HomeworkOverviewStudent({super.key});

  @override
  State<HomeworkOverviewStudent> createState() => _HomeworkOverviewStudentState();
}

class _HomeworkOverviewStudentState extends State<HomeworkOverviewStudent> with RouteAware { // RouteObserver will let you know that you have returned from another screen
  Map homeData = {};
  late MyUser myUser;
  List<Map<String, dynamic>> homeworkQuery = [];
  List<Map<String, dynamic>> studentSubmittedQuery = [];

  List<Map<String, dynamic>> studentSubmissions = [];
  bool _isDataLoaded = false;

  void getHomeworkData() async {
    homeworkQuery = await myUser.getHomeworks(myUser.className) ?? [];

    try {
      // Sort by deadline – from furthest to closest
      homeworkQuery.sort((a, b) {
        DateTime aDate = (a["deadline"] as Timestamp).toDate();
        DateTime bDate = (b["deadline"] as Timestamp).toDate();
        return bDate.compareTo(aDate); // nejpozdější deadline první
      });
    } catch (e) {
      print(e);
    }

    getHomeworkStudentData();
    
  }

  void getHomeworkStudentData() async {
    studentSubmittedQuery = await myUser.getStudentHasHomework() ?? [];
    for (var hwStudentDoc in studentSubmittedQuery) {
      for (var hwDoc in homeworkQuery) {
        if (hwStudentDoc["homeworkID"].id ==hwDoc["uid"]) {
          studentSubmissions.add(hwStudentDoc);
        }
      }
    }
    if (mounted) {  // Check if the widget is still in the tree before calling setState()
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!); // Subscribe the observer
    if (!_isDataLoaded) {
      if (homeData.isEmpty) {
        homeData = ModalRoute  // Gets data from home
            .of(context)!
            .settings
            .arguments as Map; // Access context safely here
        myUser = homeData["myUser"];
      }
      getHomeworkData();
      _isDataLoaded = true;
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Unsubscribe the observer
    super.dispose();
  }

  @override
  void didPopNext() {
    //This is called when you return from a homework detail.
    homeworkQuery.clear();
    studentSubmissions.clear();
    getHomeworkData();
  }

  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text("Student Homeworks"),
          backgroundColor: Colors.lightGreen[200],
          bottom: TabBar(
            tabs: [
              Tab(text: "Unfinished"), // First tab (tab as the button on top)
              Tab(text: "Overdue"), // Second tab
              Tab(text: "Finished"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeworkList(status: "Unfinished", homeworks: homeworkQuery, studentSubmissions: studentSubmissions, myUser: myUser), // Contents of the first tab
            HomeworkList(status: "Overdue", homeworks: homeworkQuery, studentSubmissions: studentSubmissions, myUser: myUser),    // second tab
            HomeworkList(status: "Finished", homeworks: homeworkQuery, studentSubmissions: studentSubmissions, myUser: myUser),   // third tab
          ],
        ),
      ),
    );
  }
}
