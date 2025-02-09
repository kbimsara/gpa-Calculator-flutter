import 'package:flutter/material.dart';
import '../Components/userGpaCard.dart';
import '../Models/dbHelper.dart';

class ViewPage extends StatefulWidget {
  final String name;
  final int userId;

  const ViewPage({
    super.key,
    required this.name,
    required this.userId,
  });

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _modules = [];
  int _moduleCount = 0;
  int _totalCredits = 0;
  double _gpa = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  // get db data
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final modules = await _dbHelper.getModulesByUserId(widget.userId);
      final moduleCount = await _dbHelper.getModuleCount(widget.userId);
      final totalCredits = await _dbHelper.calculateTotalCredits(widget.userId);
      final gpa = await _dbHelper.calculateGPA(widget.userId);
      
      setState(() {
        _modules = modules;
        _moduleCount = moduleCount;
        _totalCredits = totalCredits;
        _gpa = gpa;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      _showMessage('Error loading data', true);
      setState(() => _isLoading = false);
    }
  }
  // show msg
  void _showMessage(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
  // add module
  Future<void> _addModule(String name, String creditStr, String grade) async {
    try {
      final credit = int.parse(creditStr);
      if (!_dbHelper.gradePoints.containsKey(grade.toUpperCase())) {
        _showMessage('Invalid grade format', true);
        return;
      }
      
      await _dbHelper.insertModule(widget.userId, name, credit, grade.toUpperCase());
      await _loadData();
      _showMessage('Module added successfully', false);
    } catch (e) {
      _showMessage('Error adding module', true);
    }
  }
  // add module dialog
  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '', credit = '', grade = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Module'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Module Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onChanged: (value) => name = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Credits'),
                keyboardType: TextInputType.number,
                validator: (value) => int.tryParse(value ?? '') == null ? 'Enter valid number' : null,
                onChanged: (value) => credit = value,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  hintText: 'A+, A, A-, B+, etc.',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => !_dbHelper.gradePoints.containsKey(value?.toUpperCase() ?? '') 
                  ? 'Invalid grade' : null,
                onChanged: (value) => grade = value,
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
                Navigator.pop(context);
                _addModule(name, credit, grade);
              }
            },
            child: const Text('Add'),
          ),
        ],
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
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    left: 20,
                    right: 20,
                    bottom: 10
                  ),
                  child: Text(
                    'Hi, ${widget.name}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Total Module Count: $_moduleCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  'Total Credits: $_totalCredits',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  'Your GPA: ${_gpa.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 10,
                    top: 20,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            "Module",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Credit",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Results",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _modules.isEmpty
                      ? const Center(child: Text('No modules added yet'))
                      : ListView.builder(
                          itemCount: _modules.length,
                          itemBuilder: (context, index) {
                            final module = _modules[index];
                            return UserGpaCard(
                              moduleId: module['id'],
                              module_name: module['module_name'],
                              module_credit: module['credit'].toString(),
                              module_result: module['result'],
                              onUpdate: (moduleId, name, credit, result) async {
                                try {
                                  await _dbHelper.updateModule(
                                    moduleId,
                                    name,
                                    int.parse(credit),
                                    result
                                  );
                                  _loadData();
                                  _showMessage('Module updated', false);
                                } catch (e) {
                                  _showMessage('Error updating module', true);
                                }
                              },
                              onDelete: (moduleId) async {
                                try {
                                  await _dbHelper.deleteModule(moduleId);
                                  _loadData();
                                  _showMessage('Module deleted', false);
                                } catch (e) {
                                  _showMessage('Error deleting module', true);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF493D9E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Module', style: TextStyle(color: Colors.white)),
        tooltip: 'Add Module',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}