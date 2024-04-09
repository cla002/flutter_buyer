import 'package:buyers/models/report_model.dart';
import 'package:buyers/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportSeller extends StatefulWidget {
  final String sellerId;
  final String shopName;

  const ReportSeller({
    required this.sellerId,
    required this.shopName,
    super.key,
  });

  @override
  State<ReportSeller> createState() => _ReportSellerState();
}

class _ReportSellerState extends State<ReportSeller> {
  final TextEditingController _reasonController = TextEditingController();
  final _firestoreService = FirestoreService();
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _reportSeller(String reason) async {
    String buyerId = _user.uid;

    Report report = Report(
      buyerId: buyerId,
      sellerId: widget.sellerId,
      reason: reason,
      shopName: widget.shopName,
    );

    await _firestoreService.addReport(report);

    // Show a snackbar to inform the user that the report has been sent
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report sent successfully!'),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );

    // Pop the ReportSeller screen after the report is saved
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Seller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Reporting',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String reason = _reasonController.text.trim();
                if (reason.isNotEmpty) {
                  try {
                    _reportSeller(reason);
                  } catch (e) {
                    print('Error saving report: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                            'Error saving report. Please try again later.'),
                      ),
                    );
                  }
                } else {}
              },
              child: const Text('Report Seller'),
            ),
          ],
        ),
      ),
    );
  }
}
