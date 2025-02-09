import 'package:flutter/material.dart';
import '../Components/userCard.dart';
import '../Models/dbHelper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // get all users from database
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _dbHelper.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      _showMessage('Failed to load users', true);
      setState(() => _isLoading = true);
    }
  }

  // add new user
  Future<void> _addUser() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter a name', true);
      return;
    }

    try {
      final id = await _dbHelper.insertUser(name);
      if (id != -1) {
        _nameController.clear();
        _showMessage('User added successfully!', false);
        _loadUsers(); // Refresh list
      } else {
        _showMessage('Failed to add user', true);
      }
    } catch (e) {
      print('Error adding user: $e');
      _showMessage('Failed to add user', true);
    }
  }

  // msg display
  void _showMessage(String message, bool isError) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My GPA Calculator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF493D9E),
        elevation: 0.0,
      ),
      body: Column(
        children: [
          // name input
          Container(
            margin:
                const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromARGB(171, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 0.0,
                  blurRadius: 40,
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your Name',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _addUser(),
            ),
          ),

          // add user button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Add Name",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // get user list in db
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('No users added yet'))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return UserCard(
                            name: user['name'],
                            userId: user['id'],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
