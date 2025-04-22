import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/models/my_user.dart';
import 'package:project/services/local_time.dart';
import 'package:project/services/auth_service.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Declaring Variables:
  // getTimeService
  WorldTime instance = WorldTime();
  Timer? timer;

  // getUserService
  late MyUser myUser; // Declared here, so it's accessible throughout the class but initialized at innitState() (late)
  late User currentFirebaseUser;

  void getTimeService() {
    instance.getTime();
    const oneSec = Duration(seconds: 5);
    timer = Timer.periodic(oneSec, (Timer t) async {
      await instance.getTime();
      if (mounted) {  // Check if the widget is still in the tree before calling setState()
        setState(() {});
      }
    });
  }

  void getUserService() async {
    currentFirebaseUser = FirebaseAuth.instance.currentUser!;
    myUser = MyUser(currentFirebaseUser.uid);
    bool status = await myUser.getUserData();
    print("Get user service in Home widget $myUser");
    // Update state only if new data is received
    if (status) {
      if (mounted) {  // Check if the widget is still in the tree before calling setState()
        setState(() {});
      }
      checkIfAdmin();
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't get user information")));
    }
  }

  void checkIfAdmin() {
    if (myUser != null && myUser.role=="Admin") {
      Navigator.pushReplacementNamed(context, "/admin/menu", arguments: {
      "myUser" : myUser,
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserService();
    getTimeService();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,  // Prevent resizing when keyboard appears
      backgroundColor: Colors.deepPurpleAccent[100],
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/pictures/backgrounds/homeBG2.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01,
                    horizontal: screenWidth * 0.01),
                color: Colors.deepPurpleAccent[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Column(
                      children: [
                        Text(
                          instance.time,
                          style: TextStyle(
                            fontSize: screenHeight * 0.03,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Lato",
                          ),
                        ),
                        Text(
                          instance.dayOfWeek,
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Lato",
                          ),
                        ),
                      ],
                    ),
                    // Text(
                    //     instance.dayTime.toString(),
                    // ),
                    Row(
                        children: [
                          Text(
                            myUser.role,
                            style: TextStyle(
                              fontSize: screenHeight * 0.03,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Lato",
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Column(
                              children: [
                                Text(
                                  myUser.lastName,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.03,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Lato",
                                  ),
                                ),
                                Text(
                                  myUser.firstName,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.02,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Lato",
                                  ),
                                ),
                              ]
                          ),
                        ],
                    ),
                  ],
                ),
              ),
              // Main part of screen
              Opacity(
                opacity: 0.4,
                child: Center(
                  child: Container(
                    width: screenHeight*0.2,
                    height: screenHeight*0.2,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/pictures/Logo1.jpg'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: 0.85,
                child: Container(
                  width: screenWidth,
                  color: Colors.deepPurpleAccent[50],
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Column(
                    children: [
                      //SizedBox(height: screenHeight * 0.2),
                      Card(
                        color: Colors.redAccent[100],
                        elevation: 4,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(14),
                          leading: Icon(Icons.school_outlined),
                          title: Text(
                            'Grades',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            if (myUser.role == "Student") {
                              Navigator.pushNamed(context, "/home/grades/student", arguments: {
                                "myUser": myUser,
                              });
                            } else if (myUser.role == "Teacher") {
                              Navigator.pushNamed(context, "/home/teacher", arguments: {
                                "myUser": myUser,
                                "action": 1,
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        color: Colors.lightGreenAccent[100],
                        elevation: 4,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(14),
                          leading: Icon(Icons.rule_outlined),
                          title: Text(
                            'Homeworks',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            if (myUser.role == "Student") {
                              Navigator.pushNamed(context, "home/homeworks/student", arguments: {
                                "myUser": myUser,
                              });
                            } else if (myUser.role == "Teacher") {
                              Navigator.pushNamed(context, "/home/teacher", arguments: {
                                "myUser": myUser,
                                "action": 2,
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        color: Colors.yellow[300],
                        elevation: 4,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(14),
                          leading: Icon(Icons.description_outlined),
                          title: Text(
                            'Tests',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            if (myUser.role == "Student") {
                              Navigator.pushNamed(context, "home/tests/student", arguments: {
                                "myUser": myUser,
                              });
                            } else if (myUser.role == "Teacher") {
                              Navigator.pushNamed(context, "/home/teacher", arguments: {
                                "myUser": myUser,
                                "action": 3,
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.deepPurpleAccent[100],
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm Deletion'),
                              content: Text('Are you sure you want to logout?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await AuthService.logout(context: context);
                                  },
                                  child: Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        "Tap to logout",
                        style: TextStyle(
                          color: Colors.deepPurpleAccent[700],
                        ),
                      ),
                    ),
                    Text(
                      "Made by Stepan Zobal",
                      style: TextStyle(
                        color: Colors.deepPurpleAccent[400],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//return Scaffold(
//appBar: AppBar(
//title: const Text("Schoolkit"),
//backgroundColor: Colors.amber[300],
//),
