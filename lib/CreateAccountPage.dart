import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.person_add), text: 'Create User'),
              Tab(icon: Icon(Icons.people), text: 'Manage Users'),
              Tab(icon: Icon(Icons.apartment), text: 'Create Department'),
              Tab(icon: Icon(Icons.category), text: 'Create Object'),
            ],
          ),
        ),
        body:  TabBarView(
          children: [
            DashboardContent(),
            CreateUserTab(),
            ManageUsersTab(),
            CreateDepartmentTab(),
            CreateObjectTab(),
          ],
        ),
      ),
    );
  }
}
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});
  @override
  Widget build(BuildContext context) => Center(child: Text("Dashboard"));
}



class CreateObjectTab extends StatefulWidget {
  const CreateObjectTab({Key? key}) : super(key: key);

  @override
  State<CreateObjectTab> createState() => _CreateObjectTabState();
}

class _CreateObjectTabState extends State<CreateObjectTab> {
  final _formKey = GlobalKey<FormState>();
  final _objectIdController = TextEditingController();
  final _objectNameController = TextEditingController();
  final _deptIdController = TextEditingController();  // New controller for deptId
  String? _selectedDept;
  bool _isLoading = false;

  Future<List<String>> _fetchDepartments() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('departments').get();
    return snapshot.docs.map((doc) => doc['deptName'] as String).toList();
  }

  Future<void> _createObject() async {
    if (_formKey.currentState!.validate() && _selectedDept != null) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('objects').add({
          'objectId': _objectIdController.text.trim(),
          'objectName': _objectNameController.text.trim(),
          'department': _selectedDept,
          'deptId': _deptIdController.text.trim(),  // Push deptId to DB
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Object created')),
        );
        _objectIdController.clear();
        _objectNameController.clear();
        _deptIdController.clear();  // Clear deptId field
        setState(() => _selectedDept = null);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchDepartments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading departments'));
        }

        final departments = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Create Object',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _objectIdController,
                  decoration: const InputDecoration(
                    labelText: 'Object ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                  val!.isEmpty ? 'Enter Object ID' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _objectNameController,
                  decoration: const InputDecoration(
                    labelText: 'Object Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                  val!.isEmpty ? 'Enter Object Name' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedDept,
                  decoration: const InputDecoration(
                    labelText: 'Select Department',
                    border: OutlineInputBorder(),
                  ),
                  items: departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedDept = val),
                  validator: (val) =>
                  val == null ? 'Please select a department' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _deptIdController,  // New TextField for deptId
                  decoration: const InputDecoration(
                    labelText: 'Department ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                  val!.isEmpty ? 'Enter Department ID' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createObject,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Object'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// Dashboard Tab
class CreateDepartmentTab extends StatefulWidget {
  const CreateDepartmentTab({Key? key}) : super(key: key);

  @override
  State<CreateDepartmentTab> createState() => _CreateDepartmentTabState();
}

class _CreateDepartmentTabState extends State<CreateDepartmentTab> {
  final _formKey = GlobalKey<FormState>();
  final _deptIdController = TextEditingController();
  final _deptNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createDepartment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('departments').add({
          'deptId': _deptIdController.text.trim(),
          'deptName': _deptNameController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Department created')),
        );
        _deptIdController.clear();
        _deptNameController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text('Create Department', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _deptIdController,
              decoration: const InputDecoration(labelText: 'Department ID', border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? 'Enter Department ID' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _deptNameController,
              decoration: const InputDecoration(labelText: 'Department Name', border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? 'Enter Department Name' : null,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _createDepartment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Department'),
            ),
          ],
        ),
      ),
    );
  }
}

// Create User Tab
class CreateUserTab extends StatefulWidget {
  const CreateUserTab({Key? key}) : super(key: key);

  @override
  State<CreateUserTab> createState() => _CreateUserTabState();
}

class _CreateUserTabState extends State<CreateUserTab> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _employeeNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _wardNumberController = TextEditingController();

  String _selectedRole = 'RMO';
  bool _isLoading = false;

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final phone = _phoneController.text.trim();

        final existing = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          throw Exception("Phone number already exists");
        }

        await FirebaseFirestore.instance.collection('users').add({
          'phone': phone,
          'password': _passwordController.text.trim(),
          'employeeId': _employeeIdController.text.trim(),
          'employeeName': _employeeNameController.text.trim(),
          'role': _selectedRole,
          'location': _locationController.text.trim(),
          'department': _departmentController.text.trim(),
          'wardNumber': _wardNumberController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_selectedRole account created successfully')),
        );

        _phoneController.clear();
        _passwordController.clear();
        _employeeIdController.clear();
        _employeeNameController.clear();
        _locationController.clear();
        _departmentController.clear();
        _wardNumberController.clear();

        setState(() => _selectedRole = 'RMO');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _employeeIdController.dispose();
    _employeeNameController.dispose();
    _locationController.dispose();
    _departmentController.dispose();
    _wardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text('Create New User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Role Dropdown
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'RMO', child: Text('RMO')),
                DropdownMenuItem(value: 'User', child: Text('User')),
              ],
              onChanged: (value) {
                setState(() => _selectedRole = value!);
              },
            ),
            const SizedBox(height: 20),

            // Employee ID
            _buildTextField(controller: _employeeIdController, label: 'Employee ID'),
            _buildTextField(controller: _employeeNameController, label: 'Employee Name'),
            _buildTextField(controller: _phoneController, label: 'Phone Number', type: TextInputType.phone),
            _buildTextField(controller: _passwordController, label: 'Password', obscure: true),
            _buildTextField(controller: _locationController, label: 'Location'),
            _buildTextField(controller: _departmentController, label: 'Department'),
            _buildTextField(controller: _wardNumberController, label: 'Ward Number'),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading ? null : _createAccount,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Account', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (val) => val!.isEmpty ? 'Enter $label'.toLowerCase() : null,
      ),
    );
  }
}

// Manage Users Tab
class ManageUsersTab extends StatelessWidget {
  const ManageUsersTab({Key? key}) : super(key: key);

  Future<void> _deleteUser(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final user = userDoc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(user['role']?[0] ?? 'U')),
                title: Text(user['employeeName'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${user['employeeId'] ?? 'N/A'}'),
                    Text('Phone: ${user['phone'] ?? 'N/A'}'),
                    Text('Location: ${user['location'] ?? 'N/A'}'),
                    Text('Department: ${user['department'] ?? 'N/A'}'),
                    Text('Ward: ${user['wardNumber'] ?? 'N/A'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Implement edit functionality
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(userDoc.id, context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
