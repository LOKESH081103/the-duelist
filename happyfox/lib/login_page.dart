import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'main.dart';

class LoginPage extends StatefulWidget {
  final bool isTeacher;

  LoginPage({required this.isTeacher});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();

      if (isLogin) {
        // Handle Login
        final usersJson =
            prefs.getString(widget.isTeacher ? 'teachers' : 'users') ?? '[]';
        final users = List<Map<String, dynamic>>.from(
            json.decode(usersJson).map((x) => Map<String, dynamic>.from(x)));

        final user = users.firstWhere(
          (user) =>
              user['email'] == _emailController.text &&
              user['password'] == _passwordController.text,
          orElse: () => {},
        );

        if (user.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid email or password'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Save current user and role
        user['isTeacher'] = widget.isTeacher;
        await prefs.setString('currentUser', json.encode(user));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      } else {
        // Handle Sign Up
        final usersJson =
            prefs.getString(widget.isTeacher ? 'teachers' : 'users') ?? '[]';
        final users = List<Map<String, dynamic>>.from(
            json.decode(usersJson).map((x) => Map<String, dynamic>.from(x)));

        if (users.any((user) => user['email'] == _emailController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email already registered'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final newUser = {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'isTeacher': widget.isTeacher,
        };

        users.add(newUser);
        await prefs.setString(
            widget.isTeacher ? 'teachers' : 'users', json.encode(users));
        await prefs.setString('currentUser', json.encode(newUser));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      }
    }
  }

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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'UniSync',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.isTeacher
                              ? 'Teacher Portal'
                              : 'Student Portal',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 32),
                        if (!isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!isLogin && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _handleSubmit,
                          child: Text(
                            isLogin ? 'Login' : 'Sign Up',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(
                            isLogin
                                ? 'Don\'t have an account? Sign Up'
                                : 'Already have an account? Login',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
