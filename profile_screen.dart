import 'package:flutter/material.dart';
import 'package:task_master_pro/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ApiUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the API call immediately when the screen loads
    _usersFuture = _apiService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NETWORK USERS",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF00D1FF),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<ApiUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          // 1. Week 4 Requirement: Show a loading spinner while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D1FF)),
              ),
            );
          }

          // 2. Week 4 Requirement: Implement robust error handling and display appropriate messages
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Failed to Load API Data",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll("Exception:", ""),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _usersFuture = _apiService.fetchUsers();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("TRY AGAIN"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D1FF),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Week 4 Requirement: Parse response data and display using a ListView
          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(
                      0xFF00D1FF,
                    ).withValues(alpha: 0.15),
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF00D1FF),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "@${user.username.toLowerCase()}",
                          style: const TextStyle(
                            color: Color(0xFF00D1FF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email.toLowerCase(),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
