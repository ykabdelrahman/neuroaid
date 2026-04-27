/// Detailed Stroke Assessment Request Model
/// Maps comprehensive medical form data to backend-expected format
class DetailedStrokeAssessmentRequest {
  final String gender;
  final double age;
  final int hypertension;
  final int heartDisease;
  final String everMarried;
  final String workType;
  final String residenceType;
  final double avgGlucoseLevel;
  final double bmi;
  final String smokingStatus;

  DetailedStrokeAssessmentRequest({
    required this.gender,
    required this.age,
    required this.hypertension,
    required this.heartDisease,
    required this.everMarried,
    required this.workType,
    required this.residenceType,
    required this.avgGlucoseLevel,
    required this.bmi,
    required this.smokingStatus,
  });

  /// Convert to JSON for API request
  /// Maps form data to backend's expected format
  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'age': age,
      'hypertension': hypertension,
      'heart_disease': heartDisease,
      'ever_married': everMarried,
      'work_type': workType,
      'Residence_type': residenceType,
      'avg_glucose_level': avgGlucoseLevel,
      'bmi': bmi,
      'smoking_status': smokingStatus,
    };
  }

  /// Validate all fields
  static String? validate({
    required String gender,
    required String age,
    required int? hypertension,
    required int? heartDisease,
    required String everMarried,
    required String workType,
    required String residenceType,
    required String avgGlucoseLevel,
    required String bmi,
    required String smokingStatus,
  }) {
    if (gender.isEmpty) return 'Please select gender';
    if (age.isEmpty) return 'Please enter age';
    if (hypertension == null) return 'Please select hypertension status';
    if (heartDisease == null) return 'Please select heart disease status';
    if (everMarried.isEmpty) return 'Please select marital status';
    if (workType.isEmpty) return 'Please select work type';
    if (residenceType.isEmpty) return 'Please select residence type';
    if (avgGlucoseLevel.isEmpty) return 'Please enter glucose level';
    if (bmi.isEmpty) return 'Please enter BMI';
    if (smokingStatus.isEmpty) return 'Please select smoking status';

    // Validate numeric ranges
    final ageNum = double.tryParse(age);
    if (ageNum == null || ageNum < 0 || ageNum > 120) {
      return 'Age must be between 0 and 120';
    }

    final glucoseNum = double.tryParse(avgGlucoseLevel);
    if (glucoseNum == null || glucoseNum < 50 || glucoseNum > 500) {
      return 'Glucose level must be between 50 and 500';
    }

    final bmiNum = double.tryParse(bmi);
    if (bmiNum == null || bmiNum < 10 || bmiNum > 70) {
      return 'BMI must be between 10 and 70';
    }

    return null;
  }

  /// Create from form data
  factory DetailedStrokeAssessmentRequest.fromFormData({
    required String gender,
    required String age,
    required int hypertension,
    required int heartDisease,
    required String everMarried,
    required String workType,
    required String residenceType,
    required String avgGlucoseLevel,
    required String bmi,
    required String smokingStatus,
  }) {
    return DetailedStrokeAssessmentRequest(
      gender: gender,
      age: double.parse(age),
      hypertension: hypertension,
      heartDisease: heartDisease,
      everMarried: everMarried,
      workType: workType,
      residenceType: residenceType,
      avgGlucoseLevel: double.parse(avgGlucoseLevel),
      bmi: double.parse(bmi),
      smokingStatus: smokingStatus,
    );
  }
}
