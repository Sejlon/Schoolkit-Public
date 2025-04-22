import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Test extends StatelessWidget {
  final Map<String, dynamic> test;

  const Test({super.key, required this.test});

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();  // Convert to DateTime
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);  // Format it with requirements
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text((test["name"] != null && test["name"].length > 23) ? "${test["name"].substring(0, 22)}.." : test["name"] ?? "No Description", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatTimestamp(test["scheduledTime"]) ?? "" ),
            Text((test["subject"] != null && test["subject"].length > 23) ? "${test["subject"].substring(0, 22)}.." : test["subject"] ?? "No Subject"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: () {
          Navigator.pushNamed(context, "home/tests/seeTest", arguments: {
            "test" : test,
          } );
        },
      ),
    );
  }
}
