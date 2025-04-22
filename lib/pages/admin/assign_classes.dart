import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/models/my_user.dart';

class AssignClassToTeacher extends StatefulWidget {

  const AssignClassToTeacher({super.key});

  @override
  State<AssignClassToTeacher> createState() => _AssignClassToTeacherState();
}

class _AssignClassToTeacherState extends State<AssignClassToTeacher> {
  Map homeData = {};
  List<Map<String, dynamic>> databaseResponse = [];
  String? selectedTeacher;
  late MyUser myUser;

  final _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  Future<bool> addTeacherHasClass() async {
    bool status = false;
    String subject = _subjectController.text;
    String className = _classController.text;

    if (subject.isNotEmpty && className.isNotEmpty && selectedTeacher != null) {
      DocumentReference teacherRef = FirebaseFirestore.instance
          .collection('users')
          .doc(selectedTeacher);

      status = await myUser.addTeacherHasClass(className, subject, teacherRef);

      if (status) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Teacher has been assigned a class!")));
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("There was a problem with database")));
        return false;
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You must fill in all fields")));
      return false;
    }
  }

  Future<void> getAllTeachers() async {
    databaseResponse = await myUser.getAllTeachers() ?? [];
  }


@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (homeData.isEmpty) {
      homeData = ModalRoute // Gets data from home
          .of(context)!
          .settings
          .arguments as Map; // Access context safely here
      myUser = homeData["myUser"];

      Future.microtask(() async {
        await getAllTeachers(); // Wait for data
        setState(() {});        // Redraw the dropdown after loading database response
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Přiřazení třídy učiteli")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            DropdownButton<String>(
              value: selectedTeacher,
              hint: Text('Vyber učitele'),
              items: databaseResponse.map((teacher) {
                return DropdownMenuItem<String>(
                  value: teacher["uid"],
                  child: Text("${teacher["firstName"]} ${teacher["lastName"]}"),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeacher = newValue;
                });
              },
              isExpanded: true,
            ),
            // if (selectedTeacher != null)
            //   Text("Vybraný učitel: $selectedTeacher"),

            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Předmět"),
              validator: (value) =>
              value == null || value.isEmpty ? 'Zadej název předmětu' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _classController,
              decoration: const InputDecoration(labelText: "Třída"),
              validator: (value) =>
              value == null || value.isEmpty ? 'Zadej název třídy' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                bool didAddDoc = false;
                didAddDoc = await addTeacherHasClass();
                if (didAddDoc) Navigator.pop(context);
              },
              child: const Text("Přiřadit"),
            ),
          ],
        ),
      ),
    );
  }
}
