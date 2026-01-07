class CourseModel {
  final String title;
  final String topic;
  final String fileName;
  final String downloadURL;
  final String fileID;
  final String fileType;
  final dynamic
  uploadDate; // On utilise dynamic pour accepter FieldValue ou DateTime
  final String userId;

  CourseModel({
    required this.title,
    required this.topic,
    required this.fileName,
    required this.downloadURL,
    required this.fileID,
    required this.fileType,
    required this.uploadDate,
    required this.userId,
  });
  Map<String, dynamic> constructCourseData() {
    Map<String, dynamic> courseDataMap = {
      'title': title,
      'topic': topic,
      'fileName': fileName,
      'downloadURL': downloadURL,
      'fileID': fileName,
      'fileType': fileType,
      'uploadDate': uploadDate,
      'userId': userId,
    };
    return courseDataMap;
  }
}
