import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/services/database.dart';

class MyUser {
  String uid;
  String email;
  String firstName;
  String lastName;
  String role;
  String className;
  String shortcut;
  DatabaseService database;
  late DocumentReference userReference; // For Firebase

  // The constructor initializes all values, including database
  MyUser(this.uid)
      : email = "email",
        firstName = "firstName",
        lastName = "lastName",
        className = "className",
        role = "role",
        shortcut = "____",
        database = DatabaseService(uid: uid); // Initialization in the initialization list

  Future<bool> getUserData() async {   // To get user data from database and save it to this object
    userReference = database.getUserRef();
    Map<String, dynamic>? fetchedUserData = await database.getUserData(userReference);

    if (fetchedUserData != null && fetchedUserData["uid"] != null) {
      email = fetchedUserData["email"];
      firstName = fetchedUserData["firstName"];
      lastName = fetchedUserData["lastName"];
      role = fetchedUserData["role"];
      className = fetchedUserData["class"] ?? "";
      shortcut = lastName.substring(0, 2).toUpperCase() + firstName.substring(0, 2).toUpperCase();
      return true;
    }
      return false;
  }

  Future<Map<String, dynamic>?> getOthersUserData(DocumentReference userUID) async {
    Map<String, dynamic>? fetchedUserData = await database.getUserData(userUID);
    if (fetchedUserData != null) {
      print("my_user fetched data: \n");
      print(fetchedUserData);
      return fetchedUserData;
    } else {
      print("my_user return null");
      return null;
    }
  }
  Future<List<Map<String, dynamic>>?> getAllTeachers() async {
    return await database.getAllTeachers();
  }

  Future<bool> addTeacherHasClass(String className, String subject, DocumentReference teacherID) async {
    return await database.addTeacherHasClass(className, subject, teacherID);
  }


  Future<List<Map<String, dynamic>>?> getGradesData({String? studentUID, String? subject}) async {   // For Student and Teacher, {} makes these 2 parameters optional ("Named Parameters")
    return await database.getGradesData(userReference, role, studentUID: studentUID, subject: subject);
  }

  Future<List<Map<String, dynamic>>?> getTeacherHasClasses() async {  // For a teacher (for listing classes and subjects, which teacher is assigned to)
    return await database.getTeacherHasClasses(userReference);

  }
  Future<List<Map<String, dynamic>>?> getStudentsFromClass(String className) async { //For a teacher (for listing class memebers)
    return await database.getStudentsFromClass(className);
}
  Future<bool> deleteGrade(String gradeUID) async {
    return await database.deleteGrade(gradeUID);
  }

  Future<bool> addGrade(String message, int value, double weight, DocumentReference studentRef, String subject) async {
    return await database.addGrade(message, weight, value, shortcut, userReference, studentRef, subject);
  }

  Future<List<Map<String, dynamic>>?> getHomeworks(String className) async {
    return await database.getHomeworks(className: className);
  }

  Future<List<Map<String, dynamic>>?> getHomeworksBySubject(String className, String subject) async {
    return await database.getHomeworks(className: className, subject: subject);
  }

  Future<List<Map<String, dynamic>>?> getStudentHasHomework() async {
    return await database.getStudentSubmissions(userReference);
  }

  Future<bool> setStudentHasHomework(String content, bool isFinished, DocumentReference homeworkID) async {
    return await database.setStudentHasHomework(content, isFinished, homeworkID, userReference);
  }

  Future<bool> addHomework(String className, Timestamp deadline, String description, String name, String subject) async {
    return await database.addHomework(className, deadline, description, name, subject, userReference, shortcut);
  }

  Future<List<Map<String, dynamic>>?> getSubmissionsByHomework(DocumentReference homeworkID) async {
    return await database.getSubmissionsByHomework(homeworkID);
  }

  Future<bool> deleteHomework(String homeworkID) async {
    DocumentReference homeworkRef = FirebaseFirestore.instance
        .collection('homeworks')
        .doc(homeworkID);
    return await database.deleteHomework(homeworkRef);
  }

  Future<List<Map<String, dynamic>>?> getTests({required String className, String? subject}) async {
    return await database.getTests(className: className, subject: subject);
  }

  Future<bool> addTest(String className, Timestamp scheduledTime, String description, String name, String subject) async {
    return await database.addTest(className, scheduledTime, description, name, subject, userReference, shortcut);
  }

  Future<bool> deleteTest(String testID) async {
    DocumentReference testRef = FirebaseFirestore.instance
        .collection('tests')
        .doc(testID);
    return await database.deleteTest(testRef);
  }





  @override
  String toString() {
    return 'MyUser(uid: $uid, email: $email, firstName: $firstName, lastname: $lastName, role: $role class: $className)';
  }
}