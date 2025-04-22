import 'package:flutter/material.dart';
import 'package:project/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _handleLogin() async {
    // Access user input
    final email = usernameController.text;
    final password = passwordController.text;

    // login logic
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both username and password")));
      return;
    }
    try {
      bool status = await AuthService.login(email: email, password: password, context: context);
      if (status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful!")));
        Navigator.pushReplacementNamed(context, "/home",);
      }

    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("There was a problem with the database")));
    }
  }

  // void _handleRegister() {
  //   Navigator.pushNamed(context, "/register");
  // }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.deepPurpleAccent[100],
      body: SafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/pictures/LoginBG.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //SizedBox(height: screenHeight * 0.05), // 5% of screen height
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.08,
                  ),
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent[100],
                    backgroundBlendMode: BlendMode.luminosity,
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.15), // Adaptive radius
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Schoolkit",
                          style: TextStyle(
                            fontSize: screenHeight *
                                0.07, // Font size adapts to screen height
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.08,
                  ),
                  padding: EdgeInsets.all(screenHeight * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent[100],
                    backgroundBlendMode: BlendMode.luminosity,
                    borderRadius: BorderRadius.circular(screenWidth * 0.15),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Please login:",
                          style: TextStyle(
                            fontSize: screenHeight * 0.05, // Scaled font size
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            border: UnderlineInputBorder(),
                            labelText: 'Enter your email',
                            labelStyle: TextStyle(
                              fontSize:
                                  screenHeight * 0.025, // Scaled label size
                              fontWeight: FontWeight.bold, // Bold text
                              color: Colors.black, // Text color to make it pop
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0), // Emphasize focused border
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.5), // Visible non-focused border
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16, // Style of the input text
                            color: Colors.black, // Text color for the input
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
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
                              color: Colors.black, // Text color to make it pop
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0), // Emphasize focused border
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.5), // Visible non-focused border
                            ),
                          ),
                          style: TextStyle(
                            fontSize: screenHeight * 0.03,
                            color: Colors.black, // Text color for the input
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                      ]),
                ),
                FilledButton(
                  onPressed: _handleLogin,
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(
                        Size(screenWidth * 0.8, screenHeight * 0.07)),
                  ),
                  child: Text("Login",
                      style: TextStyle(
                        fontSize: 30,
                      )),
                ),
                SizedBox(height: screenHeight * 0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
