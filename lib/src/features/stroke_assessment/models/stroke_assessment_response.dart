class StrokeAssessmentResponse {
  final String riskLevel; // 'low', 'medium', 'high'
  final double riskPercentage;
  final String timestamp;
  final List<String> recommendations;

  StrokeAssessmentResponse({
    required this.riskLevel,
    required this.riskPercentage,
    required this.timestamp,
    required this.recommendations,
  });

  /// Parse the deployed backend's JSON response.
  ///
  /// Supports both the new format (`stroke_probability`, `risk_category`,
  /// `prediction_timestamp`) and the legacy gateway format (`risk_level`,
  /// `risk_percentage`, `timestamp`) so nothing breaks if the gateway is
  /// still in use for other environments.
  factory StrokeAssessmentResponse.fromJson(Map<String, dynamic> json) {
    // --- risk level ---
    // New API: "High Risk" / "Moderate Risk" / "Low Risk"
    // Legacy: "high" / "medium" / "low"
    final String riskLevel;
    if (json.containsKey('risk_category')) {
      final raw = (json['risk_category'] as String? ?? '').toLowerCase();
      if (raw.contains('high')) {
        riskLevel = 'high';
      } else if (raw.contains('moderate') || raw.contains('medium')) {
        riskLevel = 'medium';
      } else {
        riskLevel = 'low';
      }
    } else {
      riskLevel = json['risk_level'] as String? ?? 'low';
    }

    // --- risk percentage ---
    final double riskPercentage;
    if (json.containsKey('stroke_probability')) {
      riskPercentage =
          (json['stroke_probability'] as num?)?.toDouble() ?? 0.0;
    } else {
      riskPercentage = (json['risk_percentage'] as num?)?.toDouble() ?? 0.0;
    }

    // --- timestamp ---
    final String timestamp =
        json['prediction_timestamp'] as String? ??
        json['timestamp'] as String? ??
        '';

    // --- recommendations (not provided by new API) ---
    final List<String> recommendations =
        (json['recommendations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return StrokeAssessmentResponse(
      riskLevel: riskLevel,
      riskPercentage: riskPercentage,
      timestamp: timestamp,
      recommendations: recommendations,
    );
  }

  String get riskCategoryText {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return 'Low Risk';
      case 'medium':
      case 'moderate':
        return 'Moderate Risk';
      case 'high':
        return 'High Risk';
      default:
        return 'Unknown Risk';
    }
  }

  String get displayMessage {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return 'You are currently at LOW risk of stroke.';
      case 'medium':
      case 'moderate':
        return 'You are at MODERATE risk of stroke. Medical consultation is recommended.';
      case 'high':
        return 'You are at HIGH risk of stroke. Please seek medical attention.';
      default:
        return 'Unable to determine risk level. Please consult a healthcare professional.';
    }
  }
}
