import 'package:flutter/material.dart';

class Course {
  final String name;
  final String code;
  final String instructor;

  Course({
    required this.name,
    required this.code,
    required this.instructor,
  });
}

class Notes extends StatelessWidget {
  const Notes({Key? key}) : super(key: key);

  static final List<Course> courses = [
    Course(
      name: 'Data Structures',
      code: 'CS201',
      instructor: 'Dr. Smith',
    ),
    Course(
      name: 'Digital Electronics',
      code: 'EC202',
      instructor: 'Prof. Johnson',
    ),
    Course(
      name: 'Applied Mathematics',
      code: 'MA201',
      instructor: 'Dr. Williams',
    ),
    Course(
      name: 'Computer Networks',
      code: 'CS301',
      instructor: 'Prof. Davis',
    ),
    Course(
      name: 'Database Systems',
      code: 'CS302',
      instructor: 'Dr. Brown',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Notes'),
        backgroundColor: Colors.green.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseNotesPage(course: course),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      course.code.substring(0, 2),
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    course.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    '${course.code} • ${course.instructor}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CourseNotesPage extends StatelessWidget {
  final Course course;

  const CourseNotesPage({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        backgroundColor: Colors.green.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: 64,
                color: Colors.green.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No notes available for ${course.name}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for updates from ${course.instructor}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 