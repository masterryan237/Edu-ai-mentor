import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/services/auth_service.dart';

Future<int> getCount(String collectionPath) async {
  final query = await FirebaseFirestore.instance
      .collection(collectionPath)
      .where('userId', isEqualTo: AuthService().auth.currentUser!.uid)
      .get();
  return query.docs.length;
}
