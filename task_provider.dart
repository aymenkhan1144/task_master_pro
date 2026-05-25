import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_master_pro/features/tasks/screens/home_screen.dart'; // To access your TaskItem class

class TaskProvider with ChangeNotifier {
  final List<TaskItem> _tasks = [];

  List<TaskItem> get tasks => _tasks;

  // Load Tasks from SharedPreferences
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('user_tasks');
    if (savedData != null) {
      final List<dynamic> decodedList = jsonDecode(savedData);
      _tasks.clear();
      _tasks.addAll(decodedList.map((item) => TaskItem.fromMap(item)).toList());
      notifyListeners(); // Week 6 Requirement: Notifies the UI to rebuild automatically
    }
  }

  // Add a New Task
  Future<void> addTask(TaskItem task) async {
    _tasks.add(task);
    notifyListeners();
    await _saveTasksToLocal();
    await syncTaskToCloud(task);
  }

  // Delete a Task
  Future<void> deleteTask(int index) async {
    _tasks.removeAt(index);
    notifyListeners();
    await _saveTasksToLocal();
  }

  // Toggle Task Completion State
  Future<void> toggleTaskStatus(int index, bool isCompleted) async {
    _tasks[index].isCompleted = isCompleted;
    notifyListeners();
    await _saveTasksToLocal();
  }

  // Save Tasks Locally
  Future<void> _saveTasksToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'user_tasks',
      jsonEncode(_tasks.map((task) => task.toMap()).toList()),
    );
  }

  // Sync Task to Firebase Firestore
  Future<void> syncTaskToCloud(TaskItem task) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'name': task.name,
        'priorityColor': task.priorityColor.value,
        'time': task.time,
        'completed': task.isCompleted,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Firestore Provider Sync Error: $e");
    }
  }
}
