import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RMODashboard extends StatelessWidget {
  void _updateRMOStatus(DocumentSnapshot memo, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('memo')
          .doc(memo.id)
          .update({'rmoStatus': status});
    } catch (e) {
      print('Error updating RMO status: $e');
    }
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Not Approved':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Format timestamp without using intl package
  String _formatDate(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    hour = hour == 0 ? 12 : hour; // Convert 0 to 12 for 12 AM

    String minute = dateTime.minute.toString().padLeft(2, '0');

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} - $hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RMO Dashboard'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('memo').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.indigo,
                ),
              );

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No complaints found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );

            final memos = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];
                final rmoStatus = memo['rmoStatus'] ?? 'Pending';

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(rmoStatus).withOpacity(0.2),
                      child: Icon(
                        rmoStatus == 'Approved' ? Icons.check :
                        rmoStatus == 'Not Approved' ? Icons.close : Icons.pending,
                        color: _getStatusColor(rmoStatus),
                      ),
                    ),
                    title: Text(
                      'Memo ID: ${memo['memoId']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Issue: ${memo['issue']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(rmoStatus).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        rmoStatus,
                        style: TextStyle(
                          color: _getStatusColor(rmoStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Ward Number', memo['wardNumber'].toString()),
                          _buildInfoRow('User Phone', memo['userPhone']),
                          _buildInfoRow('Final Status', memo['finalStatus']),
                          _buildInfoRow('Work Taken Status', memo['workTakenStatus']),
                          _buildInfoRow('Department ID', memo['deptId'] ?? "Not Assigned"),
                          _buildInfoRow('Object ID', memo['objId'] ?? "Not Assigned"),
                          _buildInfoRow('Timestamp', _formatDate(memo['timestamp'])),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (rmoStatus != 'Approved')
                                ElevatedButton.icon(
                                  onPressed: () => _updateRMOStatus(memo, 'Approved'),
                                  icon: Icon(Icons.check_circle_outline),
                                  label: Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                              if (rmoStatus != 'Not Approved')
                                ElevatedButton.icon(
                                  onPressed: () => _updateRMOStatus(memo, 'Not Approved'),
                                  icon: Icon(Icons.cancel_outlined),
                                  label: Text('Not Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Helper widget for consistent info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade900),
            ),
          ),
        ],
      ),
    );
  }
}