import 'package:flutter/material.dart';
import 'notes.dart';
import 'startup_pitch.dart';
import 'resource.dart';
import 'study_groups.dart';

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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => option.page));
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
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
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

class HubOption {
  final String title;
  final List<Color> gradientColors;
  final Widget page;

  HubOption(
      {required this.title, required this.gradientColors, required this.page});
}

final List<HubOption> hubOptions = [
  HubOption(
      title: 'Notes',
      gradientColors: [Colors.green.shade400, Colors.green.shade900],
      page: const Notes()),
  HubOption(
      title: 'Resource Sharing',
      gradientColors: [Colors.blue.shade400, Colors.blue.shade900],
      page: ResourceSharingPage()),
  HubOption(
      title: 'Startup Pitching',
      gradientColors: [Colors.red.shade400, Colors.red.shade900],
      page: const StartupPitch()),
  HubOption(
      title: 'Study Groups',
      gradientColors: [Colors.orange.shade400, Colors.orange.shade900],
      page: StudyGroupsPage()),
  HubOption(
      title: 'Club Activities',
      gradientColors: [Colors.purple.shade400, Colors.purple.shade900],
      page: PlaceholderPage('Club Activities')),
];
