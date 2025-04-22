import 'package:flutter/material.dart';
import 'package:project/pages/admin/admin_menu.dart';
import 'package:project/pages/admin/assign_classes.dart';
import 'package:project/pages/home.dart';
import 'package:project/pages/home_actions/grades/grade_information.dart';
import 'package:project/pages/home_actions/grades/student/grades_list.dart';
import 'package:project/pages/home_actions/grades/teacher/student_grades_list.dart';
import 'package:project/pages/home_actions/homeworks/teacher/submission_information.dart';
import 'package:project/pages/home_actions/homeworks/teacher/submission_list.dart';
import 'package:project/pages/home_actions/homeworks/teacher/homework_list.dart';
import 'package:project/pages/home_actions/tests/student/overview_student.dart';
import 'package:project/pages/home_actions/tests/teacher/test_list.dart';
import 'package:project/pages/home_actions/tests/test_information.dart';
import 'package:project/pages/loading.dart';
import 'package:project/pages/login.dart';
import 'package:project/pages/admin/register.dart';
import 'package:project/pages/home_actions/grades/student/overview_student.dart';
import 'package:project/pages/home_actions/teacher_overview/overview_teacher.dart';
import 'package:project/pages/home_actions/teacher_overview/class_list.dart';
import 'package:project/pages/home_actions/grades/teacher/student_list.dart';
import 'package:project/pages/home_actions/homeworks/student/overview_student.dart';
import 'package:project/pages/home_actions/homeworks/student/homework_information.dart';


final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {

  runApp(MaterialApp(
    //initialRoute: "/admin/menu",
    navigatorObservers: [routeObserver],
    routes: {
      "/" : (context) => const Loading(),
      "/home" : (context) =>const Home(),
      "/login" : (context) => const Login(),
      "/admin/menu" : (context) => const AdminMenu(),
      "/admin/menu/register" : (context) =>const Register(),
      "/admin/menu/assign_teachers" : (context) => AssignClassToTeacher(),
      "/home/teacher" : (context) =>const OverviewTeacher(),
      "/home/teacher/classes" : (context) =>const ClassList(),
      "/home/grades/student" : (context) =>const GradesOverviewStudent(),
      "/home/grades/student/subject" : (context) =>const GradesList(),
      "/home/grades/teacher/classes/students" : (context) =>const StudentList(),
      "/home/grades/teacher/classes/students/student" : (context) =>const StudentGradesList(),
      "/home/grades/seeGrade" : (context) =>const SeeGrade(),
      "home/homeworks/student" : (context) => const HomeworkOverviewStudent(),
      "home/homeworks/student/seeHomework" : (context) => const HomeworkDetailScreen(),
      "home/homeworks/teacher/homework_list" : (context) => const HomeworkListTeacher(),
      "home/homeworks/teacher/homework_list/submissions" : (context) => const SubmissionList(),
      "home/homeworks/teacher/homework_list/submissions/details" : (context) => const SubmissionInformation(),
      "home/tests/student" : (context) => const TestOverviewStudent(),
      "home/tests/teacher" : (context) => const TestListTeacher(),
      "home/tests/seeTest" : (context) => const TestInformation(),
    },
  ));
}
