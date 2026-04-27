import 'package:equatable/equatable.dart';

/// Stroke Assessment State
/// Represents the current state of the questionnaire and assessment
abstract class StrokeAssessmentState extends Equatable {
  const StrokeAssessmentState();

  @override
  List<Object?> get props => [];
}

/// Initial state - questionnaire not started
class StrokeAssessmentInitial extends StrokeAssessmentState {
  const StrokeAssessmentInitial();
}

/// Questionnaire in progress
class StrokeAssessmentInProgress extends StrokeAssessmentState {
  final int currentQuestionIndex;
  final Map<String, int> answers;

  const StrokeAssessmentInProgress({
    required this.currentQuestionIndex,
    required this.answers,
  });

  @override
  List<Object?> get props => [currentQuestionIndex, answers];

  /// Check if this is the last question
  bool get isLastQuestion =>
      currentQuestionIndex >= 8; // 9 questions total (0-8)

  /// Get progress percentage
  double get progress => (currentQuestionIndex + 1) / 9;
}

/// Submitting assessment to backend
class StrokeAssessmentSubmitting extends StrokeAssessmentState {
  const StrokeAssessmentSubmitting();
}

/// Assessment completed successfully
class StrokeAssessmentCompleted extends StrokeAssessmentState {
  final String riskLevel;
  final String displayMessage;
  final List<String> recommendations;

  const StrokeAssessmentCompleted({
    required this.riskLevel,
    required this.displayMessage,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [riskLevel, displayMessage, recommendations];
}

/// Assessment failed
class StrokeAssessmentError extends StrokeAssessmentState {
  final String errorMessage;

  const StrokeAssessmentError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
