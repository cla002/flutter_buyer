import 'package:buyers/models/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _reportsCollection =
      FirebaseFirestore.instance.collection('reports');

  Future<void> addReport(Report report) async {
    try {
      await _reportsCollection.add(report.toMap());
    } catch (e) {
      print('Error adding report: $e');
    }
  }
}
