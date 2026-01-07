import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/models/course_model.dart';
import 'package:eduai_mentor/services/search_algolia_service.dart';
import 'package:eduai_mentor/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DbService {
  final _storageService = StorageService();
  final _algoliaService = SearchAlgoliaService();
  final userid = FirebaseAuth.instance.currentUser!.uid;

  //enregister les infos d'un cours sur la db (sur le store ou db firebase)
  Future<void> saveNewCourse(
    String localPath,
    PlatformFile? fileInfo,
    String courseName,
    String topicName,
  ) async {
    String fileID =
        "${DateTime.now().millisecondsSinceEpoch}_${fileInfo?.name}";
    final downloadURL = await _storageService.uploadFileToStorage(
      localPath,
      fileID,
    );

    if (downloadURL == null) throw Exception("Upload failed");
    final courseData = CourseModel(
      title: courseName,
      topic: topicName,
      fileName: fileInfo!.name,
      downloadURL: downloadURL,
      fileID: fileID,
      fileType: fileInfo.extension!,
      uploadDate: FieldValue.serverTimestamp(),
      userId: FirebaseAuth.instance.currentUser!.uid,
    ).constructCourseData();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('courses')
        .add(courseData);

    await _algoliaService.indexToAlgolia(
      courseName,
      topicName,
      downloadURL,
      fileID,
    );
  }

  //supprimer les infos d'un cours sur le store
  Future<void> deleteCourseFromFirestore(String docId, String fileID) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('courses')
        .doc(docId)
        .delete();
  }

  //Recuperer les 2 derniers cours uploades sur le store
  Stream<QuerySnapshot> getLatestCourses(final uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('courses')
        .orderBy('uploadDate', descending: true)
        .limit(2)
        .snapshots();
  }

  Stream<QuerySnapshot> getUploadedCourses(final uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('courses')
        .orderBy('uploadDate', descending: true)
        .snapshots();
  }

  Future<String> saveGeneratedCourseToFirestore(
    String description,
    List<int> bytes,
  ) async {
    String publicUrl;
    String fileName = '';
    (fileName, publicUrl) = await StorageService()
        .saveGeneratedCourseToSupabase(fileName, bytes);
    String shortTitle = description.length > 8
        ? description.substring(0, 8)
        : description;
    final genCourseData = CourseModel(
      title: shortTitle,
      topic: description,
      fileName: fileName,
      downloadURL: publicUrl,
      fileID: fileName,
      fileType: 'pdf',
      uploadDate: FieldValue.serverTimestamp(),
      userId: FirebaseAuth.instance.currentUser!.uid,
    ).constructCourseData();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("generated_courses")
        .add(genCourseData);
    return publicUrl;
  }
}
