import 'dart:convert';
import 'package:http/http.dart' as http;

// User model to parse and store incoming JSON API data cleanly
class ApiUser {
  final int id;
  final String name;
  final String email;
  final String username;

  ApiUser({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
  });

  // Factory constructor to parse map elements from jsonDecode
  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
    );
  }
}

class ApiService {
  // Week 4 Task: Fetch data asynchronously from a RESTful API
  Future<List<ApiUser>> fetchUsers() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/users');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        // Map each dynamic element into our ApiUser object structure
        List<ApiUser> users = body
            .map((dynamic item) => ApiUser.fromJson(item))
            .toList();
        return users;
      } else {
        throw Exception("Server responded with code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network connectivity error: ${e.toString()}");
    }
  }
}
