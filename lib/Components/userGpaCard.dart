import 'package:flutter/material.dart';
import '../Models/dbHelper.dart';

class UserGpaCard extends StatelessWidget {
  final int moduleId;
  final String module_name;
  final String module_credit;
  final String module_result;
  final Function(int, String, String, String) onUpdate;
  final Function(int) onDelete;

  const UserGpaCard({
    super.key,
    required this.moduleId,
    required this.module_name,
    required this.module_credit,
    required this.module_result,
    required this.onUpdate,
    required this.onDelete,
  });
  // Function to show popup dialog
  void _showEditDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: module_name);
    final creditController = TextEditingController(text: module_credit);
    final resultController = TextEditingController(text: module_result);
    final dbHelper = DatabaseHelper();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Module'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Module Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: creditController,
                decoration: const InputDecoration(labelText: 'Credit Count'),
                keyboardType: TextInputType.number,
                validator: (value) => int.tryParse(value ?? '') == null 
                  ? 'Enter valid number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: resultController,
                decoration: const InputDecoration(
                  labelText: 'Result',
                  hintText: 'A+, A, A-, B+, etc.',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => !dbHelper.gradePoints.containsKey(value?.toUpperCase() ?? '') 
                  ? 'Invalid grade' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                onUpdate(
                  moduleId,
                  nameController.text,
                  creditController.text,
                  resultController.text.toUpperCase(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Module'),
                  content: const Text('Are you sure you want to delete this module?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        onDelete(moduleId);
                        Navigator.pop(context); // Close confirm dialog
                        Navigator.pop(context); // Close edit dialog
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  module_name,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  module_credit,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  module_result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}