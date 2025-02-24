import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _imageBase64;
  bool _isEditing = false;
  Map<String, String> _profileData = {
    'name': 'John Doe',
    'role': 'Computer Science - Year 3',
    'email': 'john.doe@university.edu',
    'phone': '+1 234 567 8900',
    'dob': '15 Jan 2000',
    'address': '123 University Street, City',
    'department': 'Computer Science',
    'rollNumber': 'CS2021036',
    'cgpa': '3.8/4.0',
    'batch': '2021-2025',
  };

  Map<String, double> _metrics = {
    'Attendance': 0.85,
    'Assignments': 0.92,
    'Quiz Performance': 0.78,
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileData = Map.from(jsonDecode(
          prefs.getString('profileData') ?? jsonEncode(_profileData)));
      _metrics = Map.from(
          jsonDecode(prefs.getString('metricsData') ?? jsonEncode(_metrics)));
      _imageBase64 = prefs.getString('profileImage');
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileData', jsonEncode(_profileData));
    await prefs.setString('metricsData', jsonEncode(_metrics));
    if (_imageBase64 != null) {
      await prefs.setString('profileImage', _imageBase64!);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
      _saveProfileData();
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _imageBase64 != null
              ? MemoryImage(base64Decode(_imageBase64!))
              : NetworkImage('https://via.placeholder.com/150')
                  as ImageProvider,
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditableInfoRow(String icon, String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(IconData(int.parse(icon), fontFamily: 'MaterialIcons'),
              color: Colors.blue[600], size: 24),
          SizedBox(width: 16),
          Expanded(
            child: _isEditing
                ? TextFormField(
                    initialValue: _profileData[key],
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _profileData[key] = value;
                      });
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _profileData[key] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableMetric(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(_metrics[label]! * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: _metrics[label],
          backgroundColor: Colors.blue[100],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfileData();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildProfileImage(),
                    SizedBox(height: 16),
                    if (_isEditing) ...[
                      TextFormField(
                        initialValue: _profileData['name'],
                        style: TextStyle(color: Colors.white, fontSize: 24),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _profileData['name'] = value;
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: _profileData['role'],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Role',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _profileData['role'] = value;
                          });
                        },
                      ),
                    ] else ...[
                      Text(
                        _profileData['name'] ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _profileData['role'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Personal Information',
                    [
                      _buildEditableInfoRow('0xe158', 'Email', 'email'),
                      _buildEditableInfoRow('0xe4a2', 'Phone', 'phone'),
                      _buildEditableInfoRow('0xe7e9', 'Date of Birth', 'dob'),
                      _buildEditableInfoRow('0xe3ab', 'Address', 'address'),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildSection(
                    'Academic Information',
                    [
                      _buildEditableInfoRow(
                          '0xe80c', 'Department', 'department'),
                      _buildEditableInfoRow(
                          '0xe896', 'Roll Number', 'rollNumber'),
                      _buildEditableInfoRow('0xe7bd', 'CGPA', 'cgpa'),
                      _buildEditableInfoRow('0xe878', 'Batch', 'batch'),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildSection(
                    'Performance Metrics',
                    _metrics.keys
                        .map((key) => _buildEditableMetric(key))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
