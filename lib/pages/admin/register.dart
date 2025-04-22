import 'package:flutter/material.dart';
import 'package:project/services/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}
List<String> options = ["Student", "Teacher"];

class _RegisterState extends State<Register> {

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  void _handleRegister() async {
    final firstName = firstNameController.text;
    final lastName = lastNameController.text;
    final password = passwordController.text;
    final email = emailController.text;
    final className = classController.text;

    RegExp exp = RegExp(r"^[a-zA-Z0-9_.±]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$");
    bool hasMatch = exp.hasMatch(email);

    if (firstName.isEmpty || lastName.isEmpty || password.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    } else if (!hasMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email")),
      );
      return;
    } else if (currentOption == "Student" && className.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your class")),
      );
      return;
    }

    try {
      bool status = await AuthService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: currentOption,
        context: context,
        className: currentOption == "Student" ? className : null, // if it is a student, add className
      );
      if (status) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Database error, please check your connection")),
      );
    }
  }


  void _handleBack() {
    Navigator.pop(context);
  }

  String currentOption = options[0];

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.deepPurpleAccent[100],
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/pictures/LoginBG.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.01,
                      horizontal: screenWidth * 0.08,
                    ),
                    padding: EdgeInsets.all(screenHeight * 0.01),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent[100],
                      backgroundBlendMode: BlendMode.luminosity,
                      borderRadius: BorderRadius.circular(screenWidth * 0.15),
                    ),
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Register:",
                              style: TextStyle(
                                fontSize: screenHeight * 0.07,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextFormField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                border: UnderlineInputBorder(),
                                labelText: 'Enter your first name',
                                labelStyle: TextStyle(
                                  fontSize:
                                      screenHeight * 0.025, // Scaled label size
                                  fontWeight: FontWeight.bold, // Bold text
                                  color:
                                      Colors.black, // Text color
                                ),
                                focusedBorder: UnderlineInputBorder( // The field has focus (the user clicked and is typing in it).
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0),
                                ),
                                enabledBorder: UnderlineInputBorder( // The field is not focused (the user is not currently typing in it),
                                  borderSide: BorderSide(color: Colors.black, width: 2.5),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: screenHeight * 0.025, // Style of the input text
                                color: Colors.black, // Text color for the input
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextFormField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person_outline),
                                border: UnderlineInputBorder(),
                                labelText: 'Enter your last name',
                                labelStyle: TextStyle(
                                  fontSize:
                                  screenHeight * 0.025, // Scaled label size
                                  fontWeight: FontWeight.bold, // Bold text
                                  color:
                                  Colors.black, // Text color
                                ),
                                focusedBorder: UnderlineInputBorder( // The field has focus (the user clicked and is typing in it).
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0),
                                ),
                                enabledBorder: UnderlineInputBorder( // The field is not focused (the user is not currently typing in it),
                                  borderSide: BorderSide(color: Colors.black, width: 2.5),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: screenHeight * 0.025, // Style of the input text
                                color: Colors.black, // Text color for the input
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email),
                                border: UnderlineInputBorder(),
                                labelText: 'Enter your email',
                                labelStyle: TextStyle(
                                  fontSize:
                                      screenHeight * 0.025, // Scaled label size
                                  fontWeight: FontWeight.bold, // Bold text
                                  color:
                                      Colors.black,
                                ),
                                focusedBorder: UnderlineInputBorder( // The field has focus (the user clicked and is typing in it).
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0),
                                ),
                                enabledBorder: UnderlineInputBorder( // The field is not focused (the user is not currently typing in it),
                                  borderSide: BorderSide(color: Colors.black, width: 2.5),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: screenHeight * 0.025, // Style of the input text
                                color: Colors.black, // Text color for the input
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock),
                                border: UnderlineInputBorder(),
                                labelText: 'Enter your password',
                                labelStyle: TextStyle(
                                  fontSize: screenHeight * 0.025,
                                  fontWeight: FontWeight.bold, // Bold text
                                  color:
                                      Colors.black,
                                ),
                                focusedBorder: UnderlineInputBorder( // The field has focus (the user clicked and is typing in it).
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0),
                                ),
                                enabledBorder: UnderlineInputBorder( // The field is not focused (the user is not currently typing in it),
                                  borderSide: BorderSide(color: Colors.black, width: 2.5),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: screenHeight * 0.025,
                                color: Colors.black, // Text color for the input
                              ),
                            ),
                            if (currentOption=="Student") ...[ // The spread operator ( if() ...[   ] ) tells Flutter that there can be multiple widgets when the condition is true.
                              SizedBox(height: screenHeight * 0.01),
                              TextFormField(
                              controller: classController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.add_business),
                                border: UnderlineInputBorder(),
                                labelText: 'Enter class',
                                labelStyle: TextStyle(
                                  fontSize: screenHeight * 0.025,
                                  fontWeight: FontWeight.bold, // Bold text
                                  color:
                                  Colors.black,
                                ),
                                focusedBorder: UnderlineInputBorder( // The field has focus (the user clicked and is typing in it).
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0),
                                ),
                                enabledBorder: UnderlineInputBorder( // The field is not focused (the user is not currently typing in it),
                                  borderSide: BorderSide(color: Colors.black, width: 2.5),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: screenHeight * 0.025,
                                color: Colors.black, // Text color for the input
                              ),
                            ),
                            ],
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                    children: [
                                      Text("Student"),
                                      Radio(value: options[0], groupValue: currentOption, onChanged: (value){
                                        setState(() {
                                          currentOption = value!;
                                        });
                                      }),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Text("Teacher"),
                                      Radio(value: options[1], groupValue: currentOption, onChanged: (value){
                                        setState(() {
                                          currentOption = value!;
                                        });
                                      }),
                                    ]
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                  FilledButton(
                    onPressed: _handleRegister,
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(
                          Size(screenWidth * 0.8, screenHeight * 0.07)),
                    ),
                    child: Text("Register",
                        style: TextStyle(
                          fontSize: 30,
                        )),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  OutlinedButton(
                    onPressed: _handleBack,
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(
                          Size(screenWidth * 0.8, screenHeight * 0.07)),
                    ),
                    child: Text("Go Back",
                        style: TextStyle(
                          fontSize: 30,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
