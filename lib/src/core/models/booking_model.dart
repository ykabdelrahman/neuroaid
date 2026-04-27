class BookingModel {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime date;
  final String time;
  final String status;
  final String? notes;
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.doctorId,
    this.doctorName = '',
    this.doctorSpecialty = '',
    required this.date,
    required this.time,
    required this.status,
    this.notes,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String doctorName = '';
    String doctorSpecialty = '';

    if (json['doctor'] != null && json['doctor'] is Map) {
      doctorName = json['doctor']['name'] as String? ?? '';
      doctorSpecialty = json['doctor']['specialty'] as String? ?? '';
    } else {
      doctorName = json['doctorName'] as String? ?? '';
      doctorSpecialty = json['doctorSpecialty'] as String? ?? '';
    }

    return BookingModel(
      id: (json['\$id'] ?? json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      doctorId: (json['doctorId'] ?? '').toString(),
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      status: json['status'] as String? ?? 'upcoming',
      notes: json['notes'] as String?,
      createdAt: json['\$createdAt'] != null
          ? DateTime.tryParse(json['\$createdAt'] as String)
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }
}
