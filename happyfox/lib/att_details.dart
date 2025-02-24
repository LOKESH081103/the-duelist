import 'package:flutter/material.dart';

class AttendanceDetailsPage extends StatelessWidget {
  final Map<String, Map<String, dynamic>> subjects;

  AttendanceDetailsPage({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Details"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: subjects.keys.length,
          itemBuilder: (context, index) {
            String subject = subjects.keys.elementAt(index);
            int total = subjects[subject]!['total'];
            int present = subjects[subject]!['present'];

            List<int> attendanceList = List.generate(total,
                (i) => i < present ? 1 : 0); // 1 for present, 0 for absent

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      children: List.generate(
                        total,
                        (i) => CircleAvatar(
                          radius: 14,
                          backgroundColor: attendanceList[i] == 1
                              ? Colors.green
                              : Colors.red,
                          child: Text(
                            (i + 1).toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
