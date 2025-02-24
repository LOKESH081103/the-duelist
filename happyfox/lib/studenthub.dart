import 'package:flutter/material.dart';

class StudentHubPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: hubOptions.length,
          itemBuilder: (context, index) {
            return _buildHubOption(context, hubOptions[index]);
          },
        ),
      ),
    );
  }

  Widget _buildHubOption(BuildContext context, HubOption option) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => option.page));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: option.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: option.gradientColors.last.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(3, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                option.title,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotesPage extends StatelessWidget {
  final List<String> subjects = [
    'Mathematics',
    'Physics',
    'Computer Science',
    'Biology',
    'Chemistry',
    'English',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(subjects[index], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              subtitle: Text('No notes here'),
              leading: Icon(Icons.book, color: Colors.green),
              tileColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  PlaceholderPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
          child: Text(
        '$title page coming soon!',
        style: TextStyle(fontSize: 18),
      )),
    );
  }
}

// Data model for hub options
class HubOption {
  final String title;
  final List<Color> gradientColors;
  final Widget page;

  HubOption({required this.title, required this.gradientColors, required this.page});
}

// Define hub options with rich gradients
final List<HubOption> hubOptions = [
  HubOption(title: 'Notes', gradientColors: [Colors.green.shade400, Colors.green.shade900], page: NotesPage()),
  HubOption(title: 'Resource Sharing', gradientColors: [Colors.blue.shade400, Colors.blue.shade900], page: PlaceholderPage('Resource Sharing')),
  HubOption(title: 'Startup Pitching', gradientColors: [Colors.red.shade400, Colors.red.shade900], page: PlaceholderPage('Startup Pitching')),
  HubOption(title: 'Study Groups', gradientColors: [Colors.orange.shade400, Colors.orange.shade900], page: PlaceholderPage('Study Groups')),
  HubOption(title: 'Club Activities', gradientColors: [Colors.purple.shade400, Colors.purple.shade900], page: PlaceholderPage('Club Activities')),
];