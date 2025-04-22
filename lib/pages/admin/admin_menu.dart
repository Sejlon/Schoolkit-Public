import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/models/my_user.dart';
import 'package:project/services/local_time.dart';
import "package:project/services/auth_service.dart";

class AdminMenu extends StatefulWidget {
  const AdminMenu({super.key});

  @override
  State<AdminMenu> createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  WorldTime instance = WorldTime();
  Timer? timer;
  late MyUser myUser;
  late User currentFirebaseUser;

  void getTimeService() {
    instance.getTime();
    const oneSec = Duration(seconds: 5);
    timer = Timer.periodic(oneSec, (Timer t) async {
      await instance.getTime();
      setState(() {});
    });
  }

  void getUserService() async {
    currentFirebaseUser = FirebaseAuth.instance.currentUser!;
    myUser = MyUser(currentFirebaseUser.uid);
    bool status = await myUser.getUserData();
    if (status) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getUserService();
    getTimeService();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                  horizontal: screenWidth * 0.01,
                ),
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
                    Text(
                      "Admin Menu",
                      style: TextStyle(
                        fontSize: screenHeight * 0.035,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Lato",
                      ),
                    ),
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
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.05),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.9,
                      child: Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 15, horizontal: screenWidth * 0.1),
                        color: Colors.orangeAccent[100],
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.025,
                              horizontal: screenWidth * 0.06),
                          leading: Icon(Icons.person_add_alt_1),
                          title: Text(
                            'Create New User',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Roboto",
                                fontSize: screenWidth * 0.05),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, "/admin/menu/register");
                          },
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.9,
                      child: Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 15, horizontal: screenWidth * 0.1),
                        color: Colors.lightBlueAccent[100],
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.025,
                              horizontal: screenWidth * 0.06),
                          leading: Icon(Icons.class_),
                          title: Text(
                            'Assign Teacher to Class',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Roboto",
                                fontSize: screenWidth * 0.05),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, "/admin/menu/assign_teachers", arguments: {
                              "myUser" : myUser,
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                color: Colors.deepPurpleAccent[100],
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
                              content: Text(
                                  'Are you sure you want to logout?.'),
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
                            borderRadius:
                            BorderRadius.zero, // Square corners
                          )),
                      child: Text(
                        "Tap to logout",
                        style: TextStyle(
                          color: Colors.deepPurpleAccent[700],
                        ),
                      ),
                    ),
                    Text(
                      "Made by Stepan Zobal   ",
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