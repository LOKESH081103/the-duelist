import 'package:flutter/material.dart';
import 'att_details.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  Map<String, Map<String, dynamic>> subjects = {
    "Maths (MTH101)": {"total": 10, "present": 8},
    "Physics (PHY102)": {"total": 12, "present": 9},
    "Chemistry (CHE103)": {"total": 15, "present": 12},
    "Java (CSE104)": {"total": 18, "present": 14},
  };

  double calculatePercentage(int present, int total) {
    return (present / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Attendance", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("OVERALL ATTENDANCE",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      "B.Tech. Artificial Intelligence and Machine Learning - VI"),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.78,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("78.00%",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: subjects.keys.length,
                itemBuilder: (context, index) {
                  String subject = subjects.keys.elementAt(index);
                  int total = subjects[subject]!['total'];
                  int present = subjects[subject]!['present'];
                  double percentage = calculatePercentage(present, total);

                  return Card(
                    elevation: 4,
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
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.deepPurple,
                          ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("${percentage.toStringAsFixed(2)}%",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total: $total"),
                              Text("Present: $present"),
                              Text("Absent: ${total - present}"),
                            ],
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AttendanceDetailsPage(
                                        subjects: subjects),
                                  ),
                                );
                              },
                              icon: Icon(Icons.arrow_forward,
                                  color: Colors.deepPurple, size: 28),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
