import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'resource_models.dart';
import 'resource_provider.dart';
// At the top of the file, add:
export 'resource.dart' show ResourceSharingPage;

// ... rest of your resource.dart file remains the same
class ResourceSharingPage extends StatefulWidget {
  @override
  _ResourceSharingPageState createState() => _ResourceSharingPageState();
}

class _ResourceSharingPageState extends State<ResourceSharingPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    MyThingsPage(),
    RequestThingsPage(),
    SkillSharingPage(),
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
        title: Text('Resource Sharing'),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatListPage()),
              );
            },
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Items'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Find Items'),
          BottomNavigationBarItem(
              icon: Icon(Icons.psychology), label: 'Skills'),
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
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        final myItems = provider.items
            .where((item) => item.owner == provider.currentUser?.id)
            .toList();

        return Scaffold(
          body: myItems.isEmpty
              ? Center(
                  child: Text('You haven\'t shared any items yet'),
                )
              : ListView.builder(
                  itemCount: myItems.length,
                  itemBuilder: (context, index) {
                    final item = myItems[index];
                    return ResourceItemCard(item: item);
                  },
                ),
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
      },
    );
  }
}

class RequestThingsPage extends StatefulWidget {
  @override
  _RequestThingsPageState createState() => _RequestThingsPageState();
}

class _RequestThingsPageState extends State<RequestThingsPage> {
  String searchQuery = '';
  ResourceType? filterType;

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        var filteredItems = provider.searchItems(searchQuery);
        if (filterType != null) {
          filteredItems =
              filteredItems.where((item) => item.type == filterType).toList();
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search for items',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ResourceType.values.map((type) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(type.toString().split('.').last),
                            selected: filterType == type,
                            onSelected: (selected) {
                              setState(() {
                                filterType = selected ? type : null;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(child: Text('No items found'))
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return ResourceItemCard(item: filteredItems[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class SkillSharingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            tabs: [
              Tab(text: 'Offer Skills'),
              Tab(text: 'Request Skills'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SkillOfferTab(),
            SkillRequestTab(),
          ],
        ),
      ),
    );
  }
}

class SkillOfferTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        final skillItems = provider.items
            .where((item) => item.type == ResourceType.skill)
            .toList();

        return Column(
          children: [
            Expanded(
              child: skillItems.isEmpty
                  ? Center(child: Text('No skills offered yet'))
                  : ListView.builder(
                      itemCount: skillItems.length,
                      itemBuilder: (context, index) {
                        return ResourceItemCard(item: skillItems[index]);
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddItemPage(initialType: ResourceType.skill),
                    ),
                  );
                },
                child: Text('Offer a Skill'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SkillRequestTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Similar to SkillOfferTab but for skill requests
    return Center(child: Text('Skill requests coming soon!'));
  }
}

class ChatListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Messages')),
          body: ListView.builder(
            itemCount: provider.messages.length,
            itemBuilder: (context, index) {
              final message = provider.messages[index];
              return ListTile(
                title: Text(message.content),
                subtitle: Text(message.timestamp.toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        otherUserId:
                            message.senderId == provider.currentUser?.id
                                ? message.receiverId
                                : message.senderId,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class ChatDetailPage extends StatelessWidget {
  final String otherUserId;

  ChatDetailPage({required this.otherUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ResourceProvider>(
              builder: (context, provider, child) {
                final messages = provider.messages.where((m) =>
                    (m.senderId == provider.currentUser?.id &&
                        m.receiverId == otherUserId) ||
                    (m.senderId == otherUserId &&
                        m.receiverId == provider.currentUser?.id));

                return ListView(
                  children:
                      messages.map((m) => MessageBubble(message: m)).toList(),
                );
              },
            ),
          ),
          MessageInput(receiverId: otherUserId),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResourceProvider>(context);
    final isMe = message.senderId == provider.currentUser?.id;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final String receiverId;

  MessageInput({required this.receiverId});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                final provider =
                    Provider.of<ResourceProvider>(context, listen: false);
                provider.addMessage(
                  Message(
                    senderId: provider.currentUser!.id,
                    receiverId: widget.receiverId,
                    content: _controller.text,
                    timestamp: DateTime.now(),
                  ),
                );
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class ResourceItemCard extends StatelessWidget {
  final ResourceItem item;

  ResourceItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(item.title),
        subtitle: Text(item.description),
        trailing: Chip(
          label: Text(item.status.toString().split('.').last),
          backgroundColor: _getStatusColor(item.status),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ResourceDetailDialog(item: item),
          );
        },
      ),
    );
  }

  Color _getStatusColor(ResourceStatus status) {
    switch (status) {
      case ResourceStatus.available:
        return Colors.green;
      case ResourceStatus.borrowed:
        return Colors.orange;
      case ResourceStatus.completed:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class ResourceDetailDialog extends StatelessWidget {
  final ResourceItem item;

  ResourceDetailDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(item.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description: ${item.description}'),
          Text('Owner: ${item.owner}'),
          Text('Year of Study: ${item.yearOfStudy}'),
          Text('Subject: ${item.subject}'),
          Text('Status: ${item.status.toString().split('.').last}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
        if (item.status == ResourceStatus.available)
          ElevatedButton(
            onPressed: () {
              // Handle resource request
              Navigator.pop(context);
            },
            child: Text('Request'),
          ),
      ],
    );
  }
}

class AddItemPage extends StatefulWidget {
  final ResourceType? initialType;

  AddItemPage({this.initialType});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  late ResourceType _selectedType;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? ResourceType.book;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<ResourceType>(
              value: _selectedType,
              items: ResourceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _yearController,
              decoration: InputDecoration(labelText: 'Year of Study'),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter year of study';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final provider =
                      Provider.of<ResourceProvider>(context, listen: false);
                  provider.addItem(
                    ResourceItem(
                      id: DateTime.now().toString(),
                      title: _titleController.text,
                      description: _descriptionController.text,
                      owner: provider.currentUser!.id,
                      yearOfStudy: _yearController.text,
                      subject: _subjectController.text,
                      type: _selectedType,
                      datePosted: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}
