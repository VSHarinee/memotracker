import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewComplaintsPage extends StatelessWidget {
  final String userPhone;

  const ViewComplaintsPage({Key? key, required this.userPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Complaints")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('memo')
            .where('userPhone', isEqualTo: userPhone)
            .snapshots(), // Removed timestamp filter to include nulls
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No complaints found."));
          }

          final complaints = snapshot.data!.docs;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final data = complaints[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: ListTile(
                  title: Text("Issue: ${data['issue'] ?? 'N/A'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ward No: ${data['wardNumber'] ?? 'N/A'}"),
                      const SizedBox(height: 4),
                      Text("RMO Status: ${data['rmoStatus'] ?? 'Not Updated'}"),
                      Text("Work Taken Status: ${data['workTakenStatus'] ?? 'Not Updated'}"),
                      Text("Final Status: ${data['finalStatus'] ?? 'Not Updated'}"),
                      const SizedBox(height: 4),
                      Text("Memo ID: ${data['memoId'] ?? 'N/A'}"),
                      Text("Obj ID: ${data['objId'] ?? 'N/A'}"),
                      Text("Dept ID: ${data['deptId'] ?? 'N/A'}"),
                    ],
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
