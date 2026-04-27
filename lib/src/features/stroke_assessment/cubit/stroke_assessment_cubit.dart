import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/stroke_assessment_service.dart';
import '../models/stroke_assessment_request.dart';
import 'stroke_assessment_state.dart';

/// Stroke Assessment Cubit
/// Manages the questionnaire flow and backend communication
class StrokeAssessmentCubit extends Cubit<StrokeAssessmentState> {
  final StrokeAssessmentService _service;

  // Question keys in strict order - DO NOT CHANGE
  static const List<String> _questionKeys = [
    'hypertension',
    'heart_disease',
    'smoking_status',
    'age_over_55',
    'high_glucose',
    'obesity',
    'physical_inactivity',
    'previous_stroke_symptoms',
    'family_history',
  ];

  // Question texts in strict order - DO NOT CHANGE
  static const List<String> _questionTexts = [
    'Have you ever been diagnosed with high blood pressure?',
    'Have you ever been diagnosed with a heart disease?',
    'Do you currently smoke or have you smoked before?',
    'Are you older than 55 years?',
    'Have you been diagnosed with diabetes or high blood sugar?',
    'Has a doctor ever told you that you are overweight or obese?',
    'Do you usually avoid physical activity or exercise?',
    'Have you ever experienced stroke-like symptoms before?',
    'Does anyone in your close family have a history of stroke?',
  ];

  StrokeAssessmentCubit(this._service) : super(const StrokeAssessmentInitial());

  /// Start the questionnaire
  void startAssessment() {
    log('🎯 Starting stroke assessment questionnaire');
    emit(
      const StrokeAssessmentInProgress(currentQuestionIndex: 0, answers: {}),
    );
  }

  /// Answer current question and move to next
  /// answer: 1 for YES, 0 for NO
  void answerQuestion(int answer) {
    if (state is! StrokeAssessmentInProgress) {
      log('⚠️ Cannot answer question - not in progress state');
      return;
    }

    final currentState = state as StrokeAssessmentInProgress;
    final currentIndex = currentState.currentQuestionIndex;
    final questionKey = _questionKeys[currentIndex];

    log('📝 Question $currentIndex answered: $questionKey = $answer');

    // Update answers map
    final updatedAnswers = Map<String, int>.from(currentState.answers);
    updatedAnswers[questionKey] = answer;

    // Check if this was the last question
    if (currentIndex >= _questionKeys.length - 1) {
      log('✅ All questions answered, submitting to backend...');
      _submitAssessment(updatedAnswers);
    } else {
      // Move to next question
      emit(
        StrokeAssessmentInProgress(
          currentQuestionIndex: currentIndex + 1,
          answers: updatedAnswers,
        ),
      );
    }
  }

  /// Submit assessment to backend
  Future<void> _submitAssessment(Map<String, int> answers) async {
    emit(const StrokeAssessmentSubmitting());

    try {
      // Create request from answers
      final request = StrokeAssessmentRequest.fromAnswers(answers);

      // Submit to backend
      final response = await _service.submitAssessment(request);

      log('✅ Assessment completed successfully');
      log('📊 Risk Level: ${response.riskLevel}');
      log('📊 Risk Percentage: ${response.riskPercentage}%');

      // Emit completed state
      emit(
        StrokeAssessmentCompleted(
          riskLevel: response.riskLevel,
          displayMessage: response.displayMessage,
          recommendations: response.recommendations,
        ),
      );
    } catch (e) {
      log('❌ Assessment submission failed: $e');
      emit(StrokeAssessmentError(e.toString()));
    }
  }

  /// Get current question text
  String getCurrentQuestionText() {
    if (state is StrokeAssessmentInProgress) {
      final index = (state as StrokeAssessmentInProgress).currentQuestionIndex;
      return _questionTexts[index];
    }
    return '';
  }

  /// Get total number of questions
  int get totalQuestions => _questionKeys.length;

  /// Reset assessment to start over
  void resetAssessment() {
    log('🔄 Resetting stroke assessment');
    emit(const StrokeAssessmentInitial());
  }
}
