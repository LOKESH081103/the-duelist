import 'package:flutter/material.dart';
import 'resource_models.dart';

class ResourceProvider extends ChangeNotifier {
  List<ResourceItem> _items = [];
  List<Message> _messages = [];
  User? _currentUser;

  ResourceProvider() {
    // Initialize a dummy user for testing
    _currentUser = User(
      id: 'user1',
      name: 'Test User',
      yearOfStudy: '2nd Year',
    );
  }
  List<ResourceItem> get items => _items;
  List<Message> get messages => _messages;
  User? get currentUser => _currentUser;

  void addItem(ResourceItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItemStatus(String itemId, ResourceStatus status) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index] = ResourceItem(
        id: _items[index].id,
        title: _items[index].title,
        description: _items[index].description,
        owner: _items[index].owner,
        yearOfStudy: _items[index].yearOfStudy,
        subject: _items[index].subject,
        type: _items[index].type,
        datePosted: _items[index].datePosted,
        status: status,
      );
      notifyListeners();
    }
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void updateUserXP(int points) {
    if (_currentUser != null) {
      _currentUser!.experiencePoints += points;
      notifyListeners();
    }
  }

  List<ResourceItem> searchItems(String query) {
    return _items
        .where((item) =>
            item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
