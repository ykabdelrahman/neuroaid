/// Stroke Assessment Request Model
/// Maps Yes/No questionnaire answers to backend-expected format
class StrokeAssessmentRequest {
  final int hypertension;
  final int heartDisease;
  final int smokingStatus;
  final int ageOver55;
  final int highGlucose;
  final int obesity;
  final int physicalInactivity;
  final int previousStrokeSymptoms;
  final int familyHistory;

  StrokeAssessmentRequest({
    required this.hypertension,
    required this.heartDisease,
    required this.smokingStatus,
    required this.ageOver55,
    required this.highGlucose,
    required this.obesity,
    required this.physicalInactivity,
    required this.previousStrokeSymptoms,
    required this.familyHistory,
  });

  /// Convert to JSON for API request
  /// Maps questionnaire data to backend's expected format
  Map<String, dynamic> toJson() {
    return {
      'hypertension': hypertension,
      'heart_disease': heartDisease,
      'smoking_status': smokingStatus == 1 ? 'smokes' : 'never smoked',
      'age': ageOver55 == 1 ? 60 : 40, // Approximate age based on answer
      'avg_glucose_level': highGlucose == 1 ? 150.0 : 90.0,
      'bmi': obesity == 1 ? 32.0 : 24.0,
      'gender': 'Male', // Default, can be made dynamic if needed
      'work_type': 'Private', // Default
      'Residence_type': 'Urban', // Default
      // Additional metadata for backend processing
      'physical_inactivity': physicalInactivity,
      'previous_stroke_symptoms': previousStrokeSymptoms,
      'family_history': familyHistory,
    };
  }

  /// Create from questionnaire answers map
  factory StrokeAssessmentRequest.fromAnswers(Map<String, int> answers) {
    return StrokeAssessmentRequest(
      hypertension: answers['hypertension'] ?? 0,
      heartDisease: answers['heart_disease'] ?? 0,
      smokingStatus: answers['smoking_status'] ?? 0,
      ageOver55: answers['age_over_55'] ?? 0,
      highGlucose: answers['high_glucose'] ?? 0,
      obesity: answers['obesity'] ?? 0,
      physicalInactivity: answers['physical_inactivity'] ?? 0,
      previousStrokeSymptoms: answers['previous_stroke_symptoms'] ?? 0,
      familyHistory: answers['family_history'] ?? 0,
    );
  }
}
