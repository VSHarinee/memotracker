// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class RespondToComplaintsPage extends StatelessWidget {
//   final String department;
//
//   const RespondToComplaintsPage({Key? key, required this.department}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final complaintsRef = FirebaseFirestore.instance
//         .collection('memo')
//         .where('rmoStatus', whereIn: ['Pending', 'Approved'])
//         .where('deptId', isEqualTo: department);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Respond to Complaints"),
//         backgroundColor: Colors.blue,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: complaintsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting)
//             return const Center(child: CircularProgressIndicator());
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
//             return const Center(child: Text("No approved complaints for your department."));
//
//           final complaints = snapshot.data!.docs;
//
//           return ListView.builder(
//             itemCount: complaints.length,
//             itemBuilder: (context, index) {
//               final doc = complaints[index];
//               final data = doc.data() as Map<String, dynamic>;
//               final status = data['workTakenStatus'];
//
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                 child: ListTile(
//                   title: Text("Issue: ${data['issue']}"),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Ward: ${data['wardNumber']}"),
//                       Text("Status: $status"),
//                       Text("Department: ${data['deptName']}"),
//                     ],
//                   ),
//                   trailing: status == 'Pending'
//                       ? ElevatedButton(
//                     onPressed: () => _updateWorkStatus(context, doc.id, 'In Progress'),
//                     child: const Text("Take Action"),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   )
//                       : status == 'In Progress'
//                       ? ElevatedButton(
//                     onPressed: () => _updateWorkStatus(context, doc.id, 'Completed'),
//                     child: const Text("Finish"),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//                   )
//                       : const Text("Done ✅"),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   void _updateWorkStatus(BuildContext context, String docId, String newStatus) async {
//     try {
//       Map<String, dynamic> updateData = {
//         'workTakenStatus': newStatus,
//       };
//
//       if (newStatus == 'In Progress') {
//         updateData['startedAt'] = FieldValue.serverTimestamp();
//       } else if (newStatus == 'Completed') {
//         updateData['finishedAt'] = FieldValue.serverTimestamp();
//       }
//
//       await FirebaseFirestore.instance.collection('memo').doc(docId).update(updateData);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Status updated to $newStatus")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error updating status: $e")),
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RespondToComplaintsPage extends StatelessWidget {
  final String department;

  const RespondToComplaintsPage({Key? key, required this.department}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final complaintsRef = FirebaseFirestore.instance
        .collection('memo')
        .where('rmoStatus', whereIn: ['Pending', 'Approved'])
        .where('deptId', isEqualTo: department);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Respond to Complaints"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: complaintsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text("No approved complaints for your department."));

          final complaints = snapshot.data!.docs;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final doc = complaints[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['workTakenStatus'];
              final rmoStatus = data['rmoStatus'];  // Add rmoStatus to display

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: ListTile(
                  title: Text("Issue: ${data['issue']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ward: ${data['wardNumber']}"),
                      Text("Status: $status"),
                      Text("Department: ${data['deptName']}"),
                      Text("RMO Status: $rmoStatus"),  // Display the rmoStatus
                    ],
                  ),
                  trailing: status == 'Pending'
                      ? ElevatedButton(
                    onPressed: () => _updateWorkStatus(context, doc.id, 'In Progress'),
                    child: const Text("Take Action"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                      : status == 'In Progress'
                      ? ElevatedButton(
                    onPressed: () => _updateWorkStatus(context, doc.id, 'Completed'),
                    child: const Text("Finish"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  )
                      : const Text("Done ✅"),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateWorkStatus(BuildContext context, String docId, String newStatus) async {
    try {
      Map<String, dynamic> updateData = {
        'workTakenStatus': newStatus,
      };

      if (newStatus == 'In Progress') {
        updateData['startedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'Completed') {
        updateData['finishedAt'] = FieldValue.serverTimestamp();
      }

      await FirebaseFirestore.instance.collection('memo').doc(docId).update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to $newStatus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }
}
