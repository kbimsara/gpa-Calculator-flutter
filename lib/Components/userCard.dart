import 'package:flutter/material.dart';
import 'package:gpa_cal_app/main.dart';
import '../Pages/viewPage.dart';
import '../Models/dbHelper.dart';

class UserCard extends StatelessWidget {
  final String name;
  final int userId;

  const UserCard({
    super.key,
    required this.name,
    required this.userId,
  });
  // Show a dialog box/confirm the deletion of the user
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete $name and all their modules?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final dbHelper = DatabaseHelper();
                await dbHelper.deleteUser(userId);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User $name deleted')),
                  );
                }
                // Navigate to the MainApp page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainApp(),
                  ),
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error deleting user'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewPage(
                name: name,
                userId: userId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
