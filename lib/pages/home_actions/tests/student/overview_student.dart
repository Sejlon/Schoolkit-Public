import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/my_user.dart';
import 'package:project/custom_widgets/test.dart';


class TestOverviewStudent extends StatefulWidget {
  const TestOverviewStudent({super.key});

  @override
  State<TestOverviewStudent> createState() => _TestOverviewStudentState();
}

class _TestOverviewStudentState extends State<TestOverviewStudent> {
  Map homeData = {}; // Home screen data
  late MyUser myUser;
  List<Map<String, dynamic>> testQuery = []; // Database response of all tests for a class
  bool _isDataLoaded = false;
  Map<String, List<Map<String, dynamic>>> categorizedTests = {}; // Sorted by Dates   Map{   "Today" : List(test1,test2..), "This week" : List(test1,test2..)    }


  Future<void> getTests() async { // Gets test from database and
    testQuery = await myUser.getTests(className:  myUser.className) ?? [];

    // Sorts test data into categories and saves to categorizedTests Map
    for (var test in testQuery) {
      final timestamp = test["scheduledTime"] as Timestamp;
      final category = getCategoryForTest(timestamp.toDate());

      if (!categorizedTests.containsKey(category)) { // Creates an entry
        categorizedTests[category] = [];
      }
      categorizedTests[category]!.add(test); // Adds a test to the list of tests for a given category:
    }

    if (mounted) {
      setState(() {});
    }
  }

  String getCategoryForTest(DateTime testDate) {
    DateTime now = DateTime.now();
    DateTime today =  DateTime(now.year, now.month, now.day); // NO time just date
    DateTime testDay = DateTime(testDate.year, testDate.month, testDate.day); // NO time just date

    if (testDay.isBefore(today)) {
      return "Past";
    } else if (testDay.isAtSameMomentAs(today)) {  // If same day
      return "Today";
    } else if (testDay.isBefore(today.add(Duration(days: 7)))) { // If is before a week
      return "This week";
    } else if (testDay.isBefore(today.add(Duration(days: 30)))) { // If is before 30 days
      return "This month";
    } else {
      return "Later";
    }

  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();  // Convert to DateTime
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);  // Format it with requirements
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      if (homeData.isEmpty) {
        homeData = ModalRoute.of(context)!.settings.arguments as Map; // Access context safely here
        myUser = homeData["myUser"];
      }
      getTests();
      _isDataLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> itemsToDisplay = [];
    final List<String> categoryOrder = ["Today", "This week", "This month", "Later"]; // I can add "Later" here to see past tests

    // This all is to get list of all needed widgets to display
    for (var category in categoryOrder) {  // loops for all categories
      // Always adds category text first
      itemsToDisplay.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Text(
            category,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
      // Then gets all test from that one category
      final List<Map<String, dynamic>> tests = categorizedTests[category] ?? []; // List of all tests(maps) from one category
      // And finally adds all the tests(with for loop) or adds widget Text("No tests")
      if (tests.isEmpty) {
        itemsToDisplay.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text(
              "No tests scheduled.",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      } else {
        for (var test in tests) {
          itemsToDisplay.add(Test(test: test)); // Adds widget test to the List of all widgets
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Tests"),
        backgroundColor: Colors.yellow[300],
      ),
      body: ListView.builder(
        itemCount: itemsToDisplay.length,
        itemBuilder: (context, index) {
        return itemsToDisplay[index];
        },
      ),
    );
  }
}
