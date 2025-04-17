import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemoPage extends StatefulWidget {
  final String userPhone;

  const MemoPage({Key? key, required this.userPhone}) : super(key: key);

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  final TextEditingController _wardController = TextEditingController();
  String? _selectedObjectId;
  String? _selectedDeptId;
  String? _selectedObjectName;
  String? _selectedDeptName;
  List<Map<String, dynamic>> _objects = [];
  bool _isLoading = true;

  Future<void> _fetchObjects() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('objects').get();

      setState(() {
        _objects = snapshot.docs.map((doc) {
          return {
            'objId': doc.id, // use document ID
            'objName': doc['objectName'],
            'deptId': doc['deptId'],
            'deptName': doc['department'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching objects: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComplaint() async {
    if (_wardController.text.isEmpty || _selectedObjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter ward and select an object")),
      );
      return;
    }

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: widget.userPhone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
        return;
      }

      final String memoId = FirebaseFirestore.instance.collection('memo').doc().id;

      await FirebaseFirestore.instance.collection('memo').doc(memoId).set({
        'memoId': memoId,
        'issue': _selectedObjectName ?? 'Unknown Object',
        'wardNumber': _wardController.text.trim(),
        'userPhone': widget.userPhone,
        'timestamp': FieldValue.serverTimestamp(),
        'objId': _selectedObjectId,
        'objName': _selectedObjectName ?? 'Unknown Object',
        'deptId': _selectedDeptId,
        'deptName': _selectedDeptName ?? 'Unknown Department',
        'rmoStatus': 'Pending',
        'workTakenStatus': 'Pending',
        'finalStatus': 'Pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint submitted successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchObjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raise Memo Complaint"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ward Number",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _wardController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Ward Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Object",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : DropdownButton<String>(
              value: _selectedObjectId,
              hint: const Text('Select Object'),
              isExpanded: true,
              items: _objects.map((object) {
                return DropdownMenuItem<String>(
                  value: object['objId'],
                  child: Text('${object['objName']} - ${object['deptName']}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedObjectId = value;
                  final selectedObject = _objects.firstWhere((object) => object['objId'] == value);
                  _selectedDeptId = selectedObject['deptId'];
                  _selectedObjectName = selectedObject['objName'];
                  _selectedDeptName = selectedObject['deptName'];
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitComplaint,
              child: const Text("Submit Memo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _wardController.dispose();
    super.dispose();
  }
}