import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added for Week 6 State Management
import 'package:task_master_pro/services/task_provider.dart'; // Import provider
import 'package:task_master_pro/features/tasks/profile_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class TaskItem {
  String name;
  Color priorityColor;
  String time;
  bool isCompleted;

  TaskItem({
    required this.name,
    required this.priorityColor,
    required this.time,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': priorityColor.value,
      'time': time,
      'isCompleted': isCompleted,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      name: map['name'],
      priorityColor: Color(map['color']),
      time: map['time'] ?? "No Time",
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();
  Color selectedColor = Colors.cyan;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Week 6 Requirement: Trigger initial data load through the state provider asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_channel_id',
      'Task Reminders',
      description: 'Notifications for tasks',
      importance: Importance.max,
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _sendNotification(String taskName, String time) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_channel_id',
          'Task Reminders',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    await _notificationsPlugin.show(
      0,
      'Task Update! ⏰',
      'Reminder for "$taskName" at $time',
      const NotificationDetails(android: androidDetails),
    );
  }

  void _showTaskDialog({TaskItem? existingTask, int? index}) {
    if (existingTask != null) {
      _taskController.text = existingTask.name;
      selectedColor = existingTask.priorityColor;
    } else {
      _taskController.clear();
      selectedColor = Colors.cyan;
    }

    String displayTime = existingTask?.time ?? "Select Time";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text(
            existingTask == null ? "New Task" : "Edit Task",
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Task name",
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(displayTime),
                  onPressed: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setDialogState(
                        () => displayTime = picked.format(context),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                _priorityTile(
                  Colors.redAccent,
                  "High Priority",
                  setDialogState,
                ),
                _priorityTile(
                  Colors.orangeAccent,
                  "Medium Priority",
                  setDialogState,
                ),
                _priorityTile(Colors.cyan, "Low Priority", setDialogState),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  final taskProvider = Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  );

                  if (existingTask != null && index != null) {
                    // Updating an existing task via provider state mutation
                    taskProvider.deleteTask(index);
                    taskProvider.addTask(
                      TaskItem(
                        name: _taskController.text,
                        priorityColor: selectedColor,
                        time: displayTime,
                        isCompleted: existingTask.isCompleted,
                      ),
                    );
                  } else {
                    // Adding a clean global item
                    taskProvider.addTask(
                      TaskItem(
                        name: _taskController.text,
                        priorityColor: selectedColor,
                        time: displayTime,
                      ),
                    );
                  }

                  _sendNotification(_taskController.text, displayTime);
                  _taskController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityTile(Color color, String label, StateSetter setDialogState) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        radius: 10,
        child: selectedColor == color
            ? const Icon(Icons.check, size: 12, color: Colors.white)
            : null,
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      onTap: () => setDialogState(() => selectedColor = color),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Week 6 Requirement: Read tasks reactively from the state provider layer
    final taskProvider = Provider.of<TaskProvider>(context);
    final currentTasks = taskProvider.tasks;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text(
          "MY TASKS",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF00D1FF),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: currentTasks.isEmpty
          ? const Center(
              child: Text(
                "No tasks available. Add some!",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: currentTasks.length,
              itemBuilder: (context, index) {
                final task = currentTasks[index];
                return Dismissible(
                  key: Key(task.name + index.toString()),
                  onDismissed: (direction) {
                    taskProvider.deleteTask(index);
                  },
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () =>
                          _showTaskDialog(existingTask: task, index: index),
                      leading: Checkbox(
                        value: task.isCompleted,
                        activeColor: const Color(0xFF00D1FF),
                        onChanged: (value) {
                          taskProvider.toggleTaskStatus(index, value!);
                        },
                      ),
                      title: Text(
                        task.name,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        "Due: ${task.time}",
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: Icon(
                        Icons.circle,
                        color: task.priorityColor,
                        size: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        backgroundColor: const Color(0xFF00D1FF),
        child: const Icon(Icons.add),
      ),
    );
  }
}
