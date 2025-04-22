import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});


  // Firestore collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users"); // Gets collection IF it doesnt exists creates one
  final CollectionReference gradeCollection = FirebaseFirestore.instance.collection("grades"); // Gets collection IF it doesnt exists creates one
  final CollectionReference teacherHasClassCollection = FirebaseFirestore.instance.collection("teacherHasClass");
  final CollectionReference homeworkCollection = FirebaseFirestore.instance.collection("homeworks");
  final CollectionReference studentHasHomeworkCollection = FirebaseFirestore.instance.collection("studentHasHomework");
  final CollectionReference testCollection = FirebaseFirestore.instance.collection("tests");


  Future<bool> updateUserData(String firstName, String lastName, String email, String role, String? className) async {
    Map<String, dynamic> userData = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "role": role,
    };
    if (className!=null) {
      userData["class"] = className; // Adds "class" attribute only for Students
    }
    try {
      await userCollection.doc(uid).set(userData);
      return true;
    } catch (e) {
      print("Database error: Couldn't set data to database $e");
      return false;
    }

  }


  DocumentReference getUserRef() {
    // Small method to set User reference
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid);
    print("studentRef: $userRef");
    return userRef;
  }


  Future<Map<String, dynamic>?> getUserData(DocumentReference docRef) async {
    try {
      // Fetch the document snapshot asynchronously.
      DocumentSnapshot docSnapshot = await docRef.get();

      // Check if the document exists.
      if (docSnapshot.exists) {
        // Retrieve the data as a Map.
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        data["uid"] = docRef.id;
        print("database return data");
        print(data);
        return data;
      }
      print("database return null");
      return null;
    }
    catch (e) {
      print("Couldn't get data from database $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllTeachers() async {
    try {
      // Now fetch the document snapshot asynchronously, either as student or teacher
      QuerySnapshot? querySnapshot;

      querySnapshot = await userCollection
          .where('role', isEqualTo: "Teacher") // Filter by studentID
          .get();

      // Works with response puts it in maps and wraps it in one array and returns it
      if (querySnapshot != null) {
        print("Number of documents: ${querySnapshot.docs.length}");
        // Retrieve the data as a Map.
        List<Map<String, dynamic>> teacherList = [];
        // Iterate through each document and add its data to the list
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["uid"] = doc.id;
          teacherList.add(data); // Add the map to the list
        }
        print("there is list $teacherList");
        print("database getAllTeachers() has finished succesfully");
        return teacherList;
      }
      return null;
    }
    catch (e) {
      print("Couldn't get data from database $e");
      return null;
    }
  }



  Future<List<Map<String, dynamic>>?> getGradesData(DocumentReference userRef, String myUserRole, {String? studentUID, String? subject}) async {
    try {
      // Now fetch the document snapshot asynchronously, either as student or teacher
      QuerySnapshot? querySnapshot;
      if (myUserRole == "Student") {
        querySnapshot = await gradeCollection
            .where('studentID', isEqualTo: userRef) // Filter by studentID
            .get();
      }

      else if (myUserRole == "Teacher") {
        DocumentReference studentRef = userCollection.doc(studentUID);
        querySnapshot = await gradeCollection
            .where('studentID', isEqualTo: studentRef)
            .where('subject', isEqualTo: subject)
            .get();
      }

      // Works with response puts it in maps and wraps it in one array and returns it
      if (querySnapshot != null) {
        print("Number of documents: ${querySnapshot.docs.length}");
        // Retrieve the data as a Map.
        List<Map<String, dynamic>> gradesList = [];
        // Iterate through each document and add its data to the list
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["uid"] = doc.id;
          gradesList.add(data); // Add the map to the list
        }
        print("there is list $gradesList");
        print("database getGrades() has finished succesfully");
        return gradesList;
      }
      return null;
    }
    catch (e) {
      print("Couldn't get data from database $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getTeacherHasClasses(
      DocumentReference teacherRef) async {
    try {
      // Now fetch the document snapshot asynchronously, either as student or teacher
      QuerySnapshot? querySnapshot;
      querySnapshot = await teacherHasClassCollection
          .where('teacherID', isEqualTo: teacherRef)
          .get();

      if (querySnapshot != null) {
        print("Number of documents: ${querySnapshot.docs.length}");
        // Retrieve the data as a Map.
        List<Map<String, dynamic>> teacherClassesList = [];
        // Iterate through each document and add its data to the list
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          teacherClassesList.add(data); // Add the map to the list
        }
        print("there is list $teacherClassesList");
        return teacherClassesList;
      }
      return null;
    } catch (e) {
      print("Couldn't get data from database $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getStudentsFromClass(
      String className) async {
    try {
      QuerySnapshot? querySnapshot;
      querySnapshot = await userCollection
          .where('class', isEqualTo: className)
          .get();
      if (querySnapshot != null) {
        print("Number of documents: ${querySnapshot.docs.length}");
        //Retrieve the data as a Map.
        List<Map<String, dynamic>> studentsFromClassList = [];
        // Iterate through each document and add its data to the list
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["uid"] = doc.id;
          studentsFromClassList.add(data); // Add the map to the list
        }
        print("database method getStudentsFromClass $studentsFromClassList");
        return studentsFromClassList;
      }
      return null;
    } catch (e) {
      print("Couldn't get data from database $e");
      return null;
    }
  }

  Future<bool> deleteGrade(String gradeUID) async {
    try {
      await gradeCollection.doc(gradeUID).delete();
      return true;
    } catch (e) {
      print("Couldn't delete data from database $e");
      return false;
    }
  }

  Future<bool> addGrade(String message, double weight, int value,
      String shortcut, DocumentReference teacherRef,
      DocumentReference studentRef, String subject) async {
    try {
      Map<String, dynamic> gradeData = {
        "message": message,
        "weight": weight,
        "value": value,
        "createdAt": Timestamp.now(),
        "teacherShort": shortcut,
        "teacherID": teacherRef,
        "studentID": studentRef,
        "subject": subject,

      };
      await gradeCollection.doc().set(gradeData);
      return true;
    } catch (e) {
      print("Couldn't add data to the database $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getHomeworks({required String className, String? subject}) async {
    try {
      QuerySnapshot? querySnapshot;
      if (subject == null) {
        querySnapshot = await homeworkCollection
            .where('class', isEqualTo: className)
            .get();
      }
      else {
        querySnapshot = await homeworkCollection
            .where("class", isEqualTo: className)
            .where("subject", isEqualTo: subject)
            .get();
      }

      if (querySnapshot != null) {
        print("Number of documents: ${querySnapshot.docs.length}");
        //Retrieve the data as a Map.
        List<Map<String, dynamic>> homeworksList = [];
        // Iterate through each document and add its data to the list
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["uid"] = doc.id;
          homeworksList.add(data); // Add the map to the list
        }
        print("database method getHomeworks $homeworksList");
        return homeworksList;
      }
      return null;
    } catch (e) {
      print("Couldn't get data from database $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getStudentSubmissions(DocumentReference studentRef) async {
    try {
      QuerySnapshot? querySnapshot;
      querySnapshot = await studentHasHomeworkCollection
          .where('studentID', isEqualTo: studentRef) // Filter by studentID
          .get();
      if (querySnapshot != null) {
        print("Number of documents: ${querySnapshot.docs.length}");
        //Retrieve the data as a Map.
        List<Map<String, dynamic>> homeworkSubmissionsList = [];
        // Iterate through each document and add its data to the list
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["uid"] = doc.id;
          homeworkSubmissionsList.add(data); // Add the map to the list
        }
        print("database method getStudentSubmissions $homeworkSubmissionsList");
        return homeworkSubmissionsList;
      }
      return null;
    } catch (e) {
      print("Couldn't get data from database $e");
      return null;
    }
  }

  Future<bool> setStudentHasHomework(String content, bool isFinished,
      DocumentReference homeworkID, DocumentReference studentID) async {
    try {
      Map<String, dynamic> submissionData = {
        "content": content,
        "handedIn": Timestamp.now(),
        "homeworkID": homeworkID,
        "isFinished": isFinished,
        "studentID": studentID,
      };

      QuerySnapshot existing = await studentHasHomeworkCollection
          .where("homeworkID", isEqualTo: homeworkID)
          .where("studentID", isEqualTo: studentID)
          .get();

      if (existing.docs.isNotEmpty) {
        // Update first found document
        await studentHasHomeworkCollection
            .doc(existing.docs.first.id)
            .update(submissionData);
      } else {
        // Otherwise create new
        await studentHasHomeworkCollection.doc().set(submissionData);
      }

      return true;
    } catch (e) {
      print("Couldn't save submission: $e");
      return false;
    }
  }

  Future<bool> addHomework(String className, Timestamp deadline, String description, String name, String subject, DocumentReference teacherID, String teacherShort) async {
    try {
      Map<String, dynamic> homeworkData = {
        "class": className,
        "createdAt": Timestamp.now(),
        "deadline": deadline,
        "description": description,
        "name": name,
        "subject": subject,
        "teacherID": teacherID,
        "teacherShort": teacherShort,
      };
      await homeworkCollection.doc().set(homeworkData);
      return true;
    } catch (e) {
      print("Couldn't delete data from database $e");
      return false;
    }
  }

  Future<bool> addTeacherHasClass(String className, String subject, DocumentReference teacherID) async {
    try {
      Map<String, dynamic> teacherHasClassData = {
        "class": className,
        "subject": subject,
        "teacherID": teacherID,

      };
      await teacherHasClassCollection.doc().set(teacherHasClassData);
      return true;
    } catch (e) {
      print("Couldn't delete data from database $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getSubmissionsByHomework(DocumentReference homeworkRef) async {
    try {
      QuerySnapshot? querySnapshot;
      querySnapshot = await studentHasHomeworkCollection
          .where("homeworkID", isEqualTo: homeworkRef)
          .where("isFinished", isEqualTo: true)
          .get();
      if (querySnapshot != null) {
        print("Number of documents: ${querySnapshot.docs.length}");
        //Retrieve the data as a Map.
        List<Map<String, dynamic>> homeworkSubmissionsList = [];
        // Iterate through each document and add its data to the list
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["uid"] = doc.id;
          homeworkSubmissionsList.add(data); // Add the map to the list
        }
        print("database method getSubmissionsByHomework $homeworkSubmissionsList");
        return homeworkSubmissionsList;
      }
      return null;
    } catch (e) {
      print("Couldn't get data from database $e");
      return null;
    }
  }

  Future<bool> deleteHomework(DocumentReference homeworkRef) async {
    try {
      await homeworkRef.delete();
      QuerySnapshot? querySnapshot;
      querySnapshot = await studentHasHomeworkCollection
          .where("homeworkID", isEqualTo: homeworkRef)
          .get();
      if (querySnapshot != null) {
        print("Number of documents: ${querySnapshot.docs.length}");
        // Iterate through each document and delete its data from database
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      }
      return true;
    } catch (e) {
      print("Couldn't delete data from database $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getTests({ required String className, String? subject}) async {
    try {
      QuerySnapshot querySnapshot;
        if (subject != null) {
          querySnapshot = await testCollection
              .where('class', isEqualTo: className)
              .where('subject', isEqualTo: subject)
              .get();
        }
        else {
          querySnapshot = await testCollection
              .where('class', isEqualTo: className)
              .get();
        }

      // Works with response puts it in maps and wraps it in one array and returns it
      if (querySnapshot != null) {
        print("Number of documents: ${querySnapshot.docs.length}");
        // Retrieve the data as a Map.
        List<Map<String, dynamic>> testsList = [];
        // Iterate through each document and add its data to the list
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["uid"] = doc.id;
          testsList.add(data); // Add the map to the list
        }
        print("there is list $testsList");
        print("database getTests() has finished succesfully");
        return testsList;
      }
      return null;
    }
    catch (e) {
      print("Couldn't get data from database $e");
      return null;
    }
  }

  Future<bool> addTest(String className, Timestamp scheduledTime, String description, String name, String subject, DocumentReference teacherID, String teacherShort) async {
    try {
      Map<String, dynamic> homeworkData = {
        "class": className,
        "createdAt": Timestamp.now(),
        "scheduledTime": scheduledTime,
        "description": description,
        "name": name,
        "subject": subject,
        "teacherID": teacherID,
        "teacherShort": teacherShort,
      };
      await testCollection.doc().set(homeworkData);
      return true;
    } catch (e) {
      print("Couldn't delete data from database $e");
      return false;
    }
  }

  Future<bool> deleteTest(DocumentReference testRef) async {
    try {
      await testRef.delete();
      return true;
    } catch (e) {
      print("Couldn't delete data from database $e");
      return false;
    }
  }

}
