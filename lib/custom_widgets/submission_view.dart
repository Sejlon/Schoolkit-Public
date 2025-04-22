import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubmissionView extends StatelessWidget {
  final Map<String, dynamic> submission;
  final bool isOverdue;

  const SubmissionView({super.key, required this.submission, required this.isOverdue});

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Unknown";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final content = submission["content"] ?? "No content provided.";
    final handedIn = submission["handedIn"];
    final isFinished = submission["isFinished"] ?? false;

    return Card(
      color: Colors.green[50],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFinished ? Icons.check_circle : Icons.edit,
                  color: isFinished ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  isFinished ? "Submitted Answer" : "Draft Answer",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                if (isOverdue) Text(
                  "Late",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              isFinished ? "Handed in: ${_formatTimestamp(handedIn)}" : "Saved in: ${_formatTimestamp(handedIn)}",
              style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
