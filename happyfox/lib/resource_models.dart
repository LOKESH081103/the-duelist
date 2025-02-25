import 'package:flutter/material.dart';

class ResourceItem {
  final String id;
  final String title;
  final String description;
  final String owner;
  final String yearOfStudy;
  final String subject;
  final ResourceType type;
  final DateTime datePosted;
  final ResourceStatus status;
  final List<String> interestedUsers;

  ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.owner,
    required this.yearOfStudy,
    required this.subject,
    required this.type,
    required this.datePosted,
    this.status = ResourceStatus.available,
    this.interestedUsers = const [],
  });
}

enum ResourceType {
  book,
  gadget,
  skill,
}

enum ResourceStatus {
  available,
  borrowed,
  completed,
}

class User {
  final String id;
  final String name;
  final String yearOfStudy;
  int experiencePoints;
  final List<String> skills;
  final List<String> interests;

  User({
    required this.id,
    required this.name,
    required this.yearOfStudy,
    this.experiencePoints = 0,
    this.skills = const [],
    this.interests = const [],
  });
}

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });
}
