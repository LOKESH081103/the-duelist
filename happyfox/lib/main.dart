import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance.dart'; // Import AttendancePage
import 'studenthub.dart'; // Import StudentHubPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniSync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    StudentHubPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('UniSync', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group), label: 'Student Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Map<int, String?> selectedSubjects = {};

  @override
  void initState() {
    super.initState();
    _loadSavedSchedule();
  }

  Future<void> _loadSavedSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 1; i <= 4; i++) {
        selectedSubjects[i] = prefs.getString('period_$i') ?? "Not Assigned";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SchedulePage()),
            );
            _loadSavedSchedule(); // Reload timetable after schedule update
          },
          child: Text('Schedule Your Classes'),
        ),
        SizedBox(height: 20),
        Text("Your Timetable",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _buildTimetable(),
      ],
    );
  }

  Widget _buildTimetable() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue, width: 1.5),
      ),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(color: Colors.blue),
            columnWidths: {0: FixedColumnWidth(100), 1: FlexColumnWidth()},
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.blue[100]),
                children: [
                  _tableCell('Period', isHeader: true),
                  _tableCell('Subject', isHeader: true),
                ],
              ),
              for (int i = 1; i <= 4; i++)
                TableRow(
                  children: [
                    _tableCell('Period $i'),
                    _tableCell(selectedSubjects[i] ?? "Not Assigned"),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 16),
      ),
    );
  }
}

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<String> subjects = ["Maths", "Physics", "Chemistry", "Java"];
  final Map<int, String?> selectedSubjects = {};

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 1; i <= 4; i++) {
        selectedSubjects[i] = prefs.getString('period_$i') ?? null;
      }
    });
  }

  Future<void> _saveSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 4; i++) {
      if (selectedSubjects[i] != null) {
        await prefs.setString('period_$i', selectedSubjects[i]!);
      }
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Schedule saved successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule Your Classes')),
      body: Column(
        children: [
          for (int i = 1; i <= 4; i++)
            ListTile(
              title: Text("Period $i"),
              trailing: DropdownButton<String>(
                value: selectedSubjects[i],
                hint: Text("Select Subject"),
                items: subjects.map((subject) {
                  return DropdownMenuItem(value: subject, child: Text(subject));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubjects[i] = value;
                  });
                },
              ),
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveSchedule,
            child: Text("Save Schedule"),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Page'));
  }
}

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Notifications')));
  }
}
