import 'package:flutter/material.dart';

class SubjectModel {
  static List<String> getSubjects() {
    return [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'Computer Science',
      'History',
      'Economics',
      'English Literature'
    ];
  }
}

class ResourceSharingPage extends StatefulWidget {
  @override
  _ResourceSharingPageState createState() => _ResourceSharingPageState();
}

class _ResourceSharingPageState extends State<ResourceSharingPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    MyThingsPage(),
    RequestThingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resource Sharing')),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Things'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Request Things'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyThingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Your posted items will appear here. now')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemPage()),
          );
        },
      ),
    );
  }
}

class RequestThingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search for items',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Center(child: Text('Search results will appear here.')),
          ),
        ],
      ),
    );
  }
}

class AddItemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Item')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Description')),
            TextField(decoration: InputDecoration(labelText: 'Owner')),
            TextField(decoration: InputDecoration(labelText: 'Year of Study')),
            TextField(decoration: InputDecoration(labelText: 'Subject')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Post Item'),
            ),
          ],
        ),
      ),
    );
  }
}
