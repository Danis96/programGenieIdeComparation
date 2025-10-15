import 'package:flutter/foundation.dart';
import 'package:programgenieplugins/feedback/feedback_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();

  List<FeedbackModel> _feedbacks = [];
  Map<String, List<FeedbackModel>> _feedbacksBySegment = {};
  bool _isLoading = false;
  String? _error;

  List<FeedbackModel> get feedbacks => _feedbacks;
  Map<String, List<FeedbackModel>> get feedbacksBySegment => _feedbacksBySegment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> addFeedback(String segmentTitle, String comment) async {
    if (comment.trim().isEmpty) {
      _error = 'Comment cannot be empty';
      notifyListeners();
      return;
    }

    if (segmentTitle.trim().isEmpty) {
      _error = 'Segment title cannot be empty';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _feedbackService.addFeedback(segmentTitle, comment);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeedbacks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _feedbacks = await _feedbackService.getFeedbacksOnce();
      _groupFeedbacksBySegment();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _feedbacks = [];
      _feedbacksBySegment = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeedbacksBySegment(String segmentTitle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<FeedbackModel> segmentFeedbacks = await _feedbackService.getFeedbacksBySegmentOnce(segmentTitle);
      _feedbacksBySegment[segmentTitle] = segmentFeedbacks;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _feedbacksBySegment[segmentTitle] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> getFeedbackCountForSegment(String segmentTitle) async {
    try {
      return await _feedbackService.getFeedbackCountBySegment(segmentTitle);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  Future<List<String>> getAllSegmentTitles() async {
    try {
      return await _feedbackService.getAllSegmentTitles();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  List<FeedbackModel> getFeedbacksForSegment(String segmentTitle) {
    return _feedbacksBySegment[segmentTitle] ?? [];
  }

  void _groupFeedbacksBySegment() {
    _feedbacksBySegment.clear();
    for (var feedback in _feedbacks) {
      if (!_feedbacksBySegment.containsKey(feedback.segmentTitle)) {
        _feedbacksBySegment[feedback.segmentTitle] = [];
      }
      _feedbacksBySegment[feedback.segmentTitle]!.add(feedback);
    }
  }

  int getFeedbackCountForSegmentSync(String segmentTitle) {
    return _feedbacksBySegment[segmentTitle]?.length ?? 0;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
