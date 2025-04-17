import 'package:flutter/material.dart';
import 'ViewComplaintsPage.dart';
import 'memo_page.dart';
import 'respond_to_complaints_page.dart'; // Add this import

class UserDashboard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDashboard({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome ${userData['employeeName']}, this app allows you to raise and track civic complaints in your locality.',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // ✅ Raise Complaint Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemoPage(userPhone: userData['phone']),
                    ),
                  );
                },
                icon: const Icon(Icons.add_alert),
                label: const Text('Raise Complaint'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ View Complaints Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewComplaintsPage(userPhone: userData['phone']),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('View Complaints'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Respond to Complaints Button (visible only to users with department)
            if (userData['department'] != null && userData['department'].toString().trim().isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RespondToComplaintsPage(department: userData['department']),
                      ),
                    );
                  },
                  icon: const Icon(Icons.reply),
                  label: const Text('Respond to Complaints'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
