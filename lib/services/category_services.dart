import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryServices {
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
}
