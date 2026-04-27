class BookingModel {
  final int id;
  final int userId;
  final int doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime date;
  final String time;
  final String status; // 'upcoming', 'completed', 'canceled'
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
    // Extract doctor info from nested 'doctor' object or direct fields
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
      id: json['id'] as int,
      userId: json['userId'] as int,
      doctorId: json['doctorId'] as int,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
