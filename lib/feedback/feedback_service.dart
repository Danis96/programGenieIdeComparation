import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String segmentTitle;
  final String comment;
  final DateTime timestamp;

  FeedbackModel({required this.id, required this.segmentTitle, required this.comment, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {'segmentTitle': segmentTitle, 'comment': comment, 'timestamp': Timestamp.fromDate(timestamp)};
  }

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      segmentTitle: data['segmentTitle'] ?? '',
      comment: data['comment'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'feedbacks';

  Future<void> addFeedback(String segmentTitle, String comment) async {
    try {
      await _firestore.collection(_collectionName).add({'segmentTitle': segmentTitle, 'comment': comment, 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Failed to add feedback: $e');
    }
  }

  Stream<List<FeedbackModel>> getFeedbacksBySegment(String segmentTitle) {
    return _firestore.collection(_collectionName).where('segmentTitle', isEqualTo: segmentTitle).snapshots().map((snapshot) {
      final List<FeedbackModel> feedbacks = snapshot.docs.map((doc) => FeedbackModel.fromFirestore(doc)).toList();

      feedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort descending

      return feedbacks;
    });
  }

  Future<List<FeedbackModel>> getFeedbacksBySegmentOnce(String segmentTitle) async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionName).where('segmentTitle', isEqualTo: segmentTitle).get(); // Remove orderBy here

      // Sort in memory instead
      final List<FeedbackModel> feedbacks = snapshot.docs.map((doc) => FeedbackModel.fromFirestore(doc)).toList();

      feedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort descending

      return feedbacks;
    } catch (e) {
      throw Exception('Failed to fetch feedbacks for segment: $e');
    }
  }

  Future<List<FeedbackModel>> getFeedbacksOnce() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionName).orderBy('timestamp', descending: true).get();

      return snapshot.docs.map((doc) => FeedbackModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch feedbacks: $e');
    }
  }

  Future<int> getFeedbackCountBySegment(String segmentTitle) async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionName).where('segmentTitle', isEqualTo: segmentTitle).get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get feedback count for segment: $e');
    }
  }

  Future<int> getFeedbackCount() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get feedback count: $e');
    }
  }

  Future<List<String>> getAllSegmentTitles() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionName).get();
      final Set<String> segments = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['segmentTitle'] != null) {
          segments.add(data['segmentTitle'] as String);
        }
      }

      return segments.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get segment titles: $e');
    }
  }
}
