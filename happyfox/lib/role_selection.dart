import 'package:flutter/material.dart';
import 'login_page.dart';

class RoleSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[200]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to UniSync',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 48),
                  Text(
                    'Select your role',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(isTeacher: false),
                        ),
                      );
                    },
                    child: Text('Student'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(isTeacher: true),
                        ),
                      );
                    },
                    child: Text('Teacher'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
